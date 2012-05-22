import QtQuick 1.1
import com.nokia.meego 1.0

BasePage {
    id: container

     // Inline HTML with loose formatting can be
     // set on the html property.

    property alias model: tedModel
    property string applicationId: "id.co.aegis.ted"

    function reload() {
        tedModel.reload();
    }

    TedFeedModel {
        id: tedModel
        onStatusChanged: {
            if (tedModel.status == XmlListModel.Loading) {
                console.log('loading ' + tedModel.source);
                appWindow.showProgress(true);
            } else if (tedModel.status == XmlListModel.Ready) {
                var pageCount = Math.ceil((tedModel.count-5)/8) + 1;
                pageIndicator.totalPages = pageCount;
                console.log('TED data ready ' + tedModel.count + ' ' + pageCount);
                videoGridModel.clear();
                for( var i = 0; i < pageCount; i++) {
                    var lastIndex = i == 0 ? 5 : 5 + (i-1) * 8 + 8;
                    var lastIndexModel = lastIndex > tedModel.count ? tedModel.count : lastIndex
                    videoGridModel.append({ "startIndex": i == 0 ? 0 : 5 + (i-1) * 8,
                                                                     "endIndex": lastIndexModel });
                }

                tedListModel.clear();
                for (var j = 0; j < tedModel.count; j++) {
                    console.log(JSON.stringify(tedModel.get(j)));
                    tedListModel.append(JSON.parse(JSON.stringify(tedModel.get(j))));
                }

                notifHelper.activate();
                notifHelper.registerApplication(applicationId);

                appWindow.showProgress(false);
            } else if (tedModel.status == XmlListModel.Error) {
                console.log('error ' + tedModel.errorString());
                appWindow.showError(tedModel.errorString());
                appWindow.showProgress(false);
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

        visible: !isLandscape
    }

    /*Label {
        id: pageLabel
        text: 'Talks'
        anchors { left: tedLogo.right; bottom: parent.bottom; }
        anchors { leftMargin: 10; bottomMargin: 4; }
        font.pixelSize: 24
    }*/

    ListView {
        id: mainListView
        anchors.fill: parent
        anchors.bottomMargin: 30
        highlightRangeMode: ListView.StrictlyEnforceRange
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        onCurrentItemChanged: {
            pageIndicator.currentPage = currentIndex + 1;
        }
        model: videoGridModel
        delegate: VideoGridDelegate {
            onClicked: {
                console.log('video index ' + index + ' - ' + tedModel.get(index).subtitle);
                pageStack.push(Qt.resolvedUrl("VideoPage.qml"),
                               {
                                   pageIndex: index,
                                   singleContentModel: tedListModel,
                                   modelSource: 1
                               }
                               );
            }
        }
    }

    ListModel { id: videoGridModel }
    ListModel { id: tedListModel }

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


    Connections{
        target: appWindow
        onSearch:

            pageStack.push(Qt.resolvedUrl("SearchPage.qml"),
                           {
                               offlineModel: tedListModel
                           }
                           );

    }


    onStatusChanged: {
        if(status == PageStatus.Active) {
            tedModel.source = "http://feeds.feedburner.com/tedtalks_video";
            commonTools.visible = true;
            // wake.setScreenSaverInhibit(false);
        }
    }

    tools: commonTools
}
