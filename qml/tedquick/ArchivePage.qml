import QtQuick 1.1
import com.nokia.meego 1.0
import 'Storage.js' as Storage

BasePage {
    id: container

    property alias model: archivedTedModel
    property int activeIndex: -1

    property int activePercentage: 0
    property int activeGridIndex: Math.floor(mainListView.currentIndex/8) + activeIndex

    property bool inEditModePage: false

    property alias count: archivedTedModel.count

    function setEditMode(edit) {
        inEditModePage = false;
    }

    function clearArchive() {
        if(archivedTedModel.count)
        queryClearCache.open();
    }

    function loadStorage() {
        var res = Storage.loadArchive(archivedTedModel);
        if (res == 'OK') {
            var pageCount = Math.ceil((archivedTedModel.count)/8);
            pageIndicator.totalPages = pageCount;
            videoGridModelArchive.clear();
            for( var i = 0; i < pageCount; i++) {
                var lastIndex = (i+1)*8 > archivedTedModel.count ? archivedTedModel.count : (i+1)*8
                videoGridModelArchive.append({ "startIndex": i*8, "endIndex": lastIndex });
            }
        } else {
            archivedTedModel.clear();
            videoGridModelArchive.clear();
        }
    }

    function download(object) {

        if(!Storage.exist(object.guid)){

            Storage.addArchive(object.guid, JSON.stringify(object));
            loadStorage();

            var downloadActiveExist = -1;
            for (var i = 0; i < archivedTedModel.count; i++) {
                if (archivedTedModel.get(i).status == 1) {
                    downloadActiveExist = i;
                    break;
                }
            }

            if (downloadActiveExist == -1) {
                console.log("downloadActiveExist -1");
                activeIndex = archivedTedModel.count - 1;

                console.log("activeIndex: " + activeIndex);

                archivedTedModel.get(activeIndex).status = 1;
                Storage.updateArchiveDetail(archivedTedModel.get(activeIndex).guid, JSON.stringify(archivedTedModel.get(activeIndex)));

                downloadManager.setFileInfo(object.downloadUrl);
                downloadManager.download();

                appWindow.showInfo('Downloading ' + object.subtitle);


            } else {

                appWindow.showInfo('Queueing ' + object.subtitle);
            }

        }
        else{
            // TODO remove download toolbutton on page whenever the talk is already downloaded
            appWindow.showInfo('This talk : ' + object.subtitle + ' is already downloaded');
        }


        /*if (!Storage.exist(object.guid)) {


            Storage.addArchive(object.guid,
                               JSON.stringify(object));

            loadStorage();

            var downloadActiveExist = -1;
            for (var i = 0; i < archivedTedModel.count; i++) {
                if (archivedTedModel.get(i).status == 1) {
                    downloadActiveExist = i;
                    break;
                }
            }

            if (downloadActiveExist == -1) {
                activeIndex = archivedTedModel.count - 1;
                archivedTedModel.get(activeIndex).status = 1;
                Storage.updateArchiveDetail(archivedTedModel.get(activeIndex).guid,
                                            JSON.stringify(archivedTedModel.get(activeIndex)));
                //downloadManager.download(object.origLink, object.baseName);
                appWindow.showInfo('Downloading ' + object.subtitle);
            } else {
                appWindow.showInfo('Putting ' + object.subtitle + ' in download queue');
                console.log('there is another download active');
            }
        }
        else {
            appWindow.showInfo('This talk : ' + object.subtitle + ' is already downloaded');
        }*/

    }



    QueryDialog {
        property int deleteIndex: 0
        id: queryDeleteItem
        titleText: "Delete talk"
        acceptButtonText: "Yes"
        rejectButtonText: "Cancel"
        onAccepted: {
            if (archivedTedModel.get(deleteIndex).status == 1) {
                downloadManager.pause();
            }

            downloadManager.deleteVideo(archivedTedModel.get(deleteIndex).baseName);

            Storage.deleteArchiveByGuid(archivedTedModel.get(deleteIndex).guid);
            loadStorage();
            var pageCount = Math.ceil((archivedTedModel.count)/8);
            pageIndicator.totalPages = pageCount;

            downloadManager.pause();

            activeIndex = -1;

            for (var i = 0; i < archivedTedModel.count; i++) {
                if (archivedTedModel.get(i).status == 1) {
                    activeIndex = i;
                    console.log("activeIndex: " + activeIndex);
                    break;
                }
            }

            if (activeIndex > -1) {
                console.log('active download at ' + activeIndex);
                var url = archivedTedModel.get(activeIndex).downloadUrl == '' ?
                        archivedTedModel.get(activeIndex).origLink : archivedTedModel.get(activeIndex).downloadUrl;
                downloadManager.setFileInfo(archivedTedModel.get(activeIndex).downloadUrl);
                downloadManager.resume();

            }
        }
        onRejected: {}
    }

    QueryDialog {
        id: queryClearCache
        titleText: "Clear Downloads"
        message: "All downloaded data, including videos, will lost. Continue?"
        acceptButtonText: "Yes"
        rejectButtonText: "Cancel"
        onAccepted: {
            for (var i = 0; i < archivedTedModel.count; i++) {
                downloadManager.deleteVideo(archivedTedModel.get(i).baseName);
            }
            downloadManager.pause();
            Storage.deleteArchive();
            loadStorage();
            var pageCount = Math.ceil((archivedTedModel.count)/8);
            pageIndicator.totalPages = pageCount;

        }
        onRejected: {}
    }

    Component.onCompleted: {
        loadStorage();

        activeIndex = -1;

        for (var i = 0; i < archivedTedModel.count; i++) {
            if (archivedTedModel.get(i).status == 1) {
                activeIndex = i;
                console.log("activeIndex: " + activeIndex);
                break;
            }
        }

        if (activeIndex > -1) {
            console.log('active download at ' + activeIndex);
            var url = archivedTedModel.get(activeIndex).downloadUrl == '' ?
                    archivedTedModel.get(activeIndex).origLink : archivedTedModel.get(activeIndex).downloadUrl;
            downloadManager.setFileInfo(archivedTedModel.get(activeIndex).downloadUrl);
            downloadManager.resume();

        }

        console.log("lastactiveIndex: " + activeIndex);
    }

    Component.onDestruction: {
        if (activeIndex > -1) {
            Storage.updateArchiveDetail(archivedTedModel.get(activeIndex).guid,
                                        JSON.stringify(archivedTedModel.get(activeIndex)));
        }

        // update when destruct
    }

    Connections {
        target: downloadManager
        onDownloadComplete: {

            console.log('download complete: ' +  name)

            archivedTedModel.get(activeIndex).status = 2;
            Storage.updateArchiveDetail(archivedTedModel.get(activeIndex).guid,
                                        JSON.stringify(archivedTedModel.get(activeIndex)));


            var nextIndex = activeIndex + 1;

            if (nextIndex < archivedTedModel.count) {
                activeIndex = nextIndex;
                // downloadManager.download(archivedTedModel.get(activeIndex).origLink, archivedTedModel.get(activeIndex).baseName);
                // archivedTedModel.get(activeIndex).status = 1;

                var aTedModel = archivedTedModel.get(activeIndex);
                aTedModel.status = 1;
                archivedTedModel.set(activeIndex, aTedModel);

                Storage.updateArchiveDetail(archivedTedModel.get(activeIndex).guid, JSON.stringify(archivedTedModel.get(activeIndex)));
                downloadManager.setFileInfo(archivedTedModel.get(activeIndex).downloadUrl);
                downloadManager.download();

            }

            appWindow.showInfo('Complete! ' + archivedTedModel.get(activeIndex).subtitle);
        }



        onProgress: {
            if(activeIndex != undefined){
                //console.log("qml %: " + percentage);

                var aTedModel = archivedTedModel.get(activeIndex);
                aTedModel.percentage = percentage;
                archivedTedModel.set(activeIndex, aTedModel);
                activePercentage = percentage;
            }
        }

        onError : {


            if (archivedTedModel.get(activeIndex).status == 1) {
                downloadManager.pause();
            }

            downloadManager.deleteVideo(archivedTedModel.get(deleteIndex).baseName);

            Storage.deleteArchiveByGuid(archivedTedModel.get(deleteIndex).guid);
            loadStorage();

            activeIndex = -1;

            for (var i = 0; i < archivedTedModel.count; i++) {
                if (archivedTedModel.get(i).status == 1) {
                    activeIndex = i;
                    console.log("activeIndex: " + activeIndex);
                    break;
                }
            }

            if (activeIndex > -1) {
                console.log('active download at ' + activeIndex);
                var url = archivedTedModel.get(activeIndex).downloadUrl == '' ?
                        archivedTedModel.get(activeIndex).origLink : archivedTedModel.get(activeIndex).downloadUrl;
                downloadManager.setFileInfo(archivedTedModel.get(activeIndex).downloadUrl);
                downloadManager.resume();

            }

        }
    }

    Image {
        id: tedLogo
        source: "images/tedlogo.png"
        anchors { left: parent.left; top: parent.top; }
        anchors { leftMargin: 40; bottomMargin: 10;}
        smooth: true
        height: 40
        fillMode: Image.PreserveAspectFit

        visible: !appWindow.isLandscape
    }

    ListView {
        id: mainListView
        // anchors.fill: parent
        // anchors.bottomMargin: 30

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: appWindow.isLandscape ? 0 : 40
            leftMargin: appWindow.isLandscape ? 0 : 28
        }

        /*MouseArea{
            id: areaBox
            anchors.fill: parent
            onPressAndHold: {
                setEditMode(true);
                console.log("holddddd");
            }
        }*/

        highlightRangeMode: ListView.StrictlyEnforceRange
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        onCurrentItemChanged: {
            pageIndicator.currentPage = currentIndex + 1;
            inEditModePage = false;
        }
        model: videoGridModelArchive
        delegate: ArchiveGridDelegate {
            activeIndex:  activeGridIndex
            percentage: activePercentage
            onClicked: {
                console.log('video index ' + index + ' - ' + archivedTedModel.get(index).subtitle);
                pageStack.push(Qt.resolvedUrl("VideoPage.qml"), {
                                   pageIndex: index,
                                   singleContentModel: archivedTedModel,
                                   modelSource:2
                               });
            }
            onDeleteItem: {
                console.log('delete video index ' + index + ' - ' + archivedTedModel.get(index).subtitle);
                queryDeleteItem.deleteIndex = index;
                queryDeleteItem.message = "You are going to delete "+ archivedTedModel.get(index).subtitle +". Including downloaded video. Continue?"
                queryDeleteItem.open();
            }

            onInEditMode: {
                inEditModePage = true;
            }

            Component.onCompleted: {
                if(inEditModePage){
                    inEditMode();
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: archivedTedModel.count == 0
        text: '"Your downloaded videos will be here"'
        font.pixelSize: 42
        horizontalAlignment: Text.AlignHCenter

        wrapMode: Text.WordWrap
        width: parent.width - 100

        color: "gray"
    }

    ListModel { id: videoGridModelArchive }
    ListModel { id: archivedTedModel }

    Item{
        id: indicator
        width: parent.width
        height: 30
        anchors.bottom: parent.bottom

        PageIndicator{
            inverted: true
            id: pageIndicator
            anchors.centerIn: parent
            currentPage: 1
            totalPages: 1
        }
    }

    onStatusChanged: {
        if(status == PageStatus.Active) {
            track.url = "http://aegis.no.de/ted/?ver=" + appWindow.version + "&os=MeeGo&page=archivePage"
        }
    }


    tools: commonTools
}
