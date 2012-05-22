import QtQuick 1.1
import com.nokia.meego 1.0

import 'Storage.js' as Storage

BasePage {
    id: container

    property ListModel singleContentModel: ListModel{}
    property int pageIndex: 0
    property int viewMode: 0
    property int modelSource: 0

    /*Connections {
        target: downloadManager
        onVideoUrl: {
            appWindow.showProgress(false);
            Qt.openUrlExternally(url);
        }
        onError: {
            appWindow.showProgress(false);
            appWindow.showError(error);
        }
    }*/

    function streamingUrl(s){

        var a = s.split('_')[1].split('.')[0];
        var b = s.split('/')[4].split('.')[0];

        var prefix = 'http://video.ted.com/talk/stream/';
        var midfix = a + '/' + 'None' + '/' + b; // None, Blogger, People (low, mid, high)
        var suffix = '-320k.mp4';

        return (prefix + midfix + suffix);
    }

    function baseName(s){
        return s.split('/')[4].split('.')[0];
    }

    function donwloadUrl(s){

        var a = s.split('_')[1].split('.')[0];
        var b = s.split('/')[4].split('.')[0];

        var prefix = 'http://video.ted.com/talk/podcast/';
        var midfix = a + '/' + 'None' + '/' + b; // None, Blogger, People (low, mid, high)
        var suffix = '.mp4';

        return (prefix + midfix + suffix);
    }

    function path(s){
        // origUrl
        return s.split('http://www.ted.com')[1];
    }



    Item {
        id: root
        anchors.fill: parent
        visible: viewMode == 0

        Item {
            id: posterArea
            anchors { top: parent.top; left: parent.left }
            anchors { topMargin: 10; leftMargin: 10 }
            width: 413
            height: 310

            MouseArea{
                id: posterAreaMouse
                anchors.fill: parent
                onClicked: {

                    console.log(modelSource);

                    track.url = "http://aegis.no.de/ted/?ver=" + appWindow.version + "&os=MeeGo&page=archivePage&activity=play&type=" + singleContentModel.get(pageIndex).origUrl

                    if (modelSource == 1) {
                        // var baseName = singleContentModel.get(pageIndex).origLink.substring(singleContentModel.get(pageIndex).origLink.lastIndexOf('/')+1);
                        // downloadManager.exists(container.baseName(singleContentModel.get(pageIndex).origUrl))


                        if (downloadManager.exists(container.baseName(singleContentModel.get(pageIndex).origLink) + ".mp4")) {

                            pageStack.push(Qt.resolvedUrl("Player.qml"), {
                                               url: downloadManager.getFullPath(container.baseName(singleContentModel.get(pageIndex).origLink) + ".mp4"),
                                               subtitlePath : path(singleContentModel.get(pageIndex).origUrl)
                                           });

                            //var filename1 = downloadManager.getFullName(baseName);
                            //console.log(filename1);
                            //Qt.openUrlExternally(filename1);

                            /*pageStack.push(Qt.resolvedUrl("Player.qml"), {
                                               url: streamingUrl(singleContentModel.get(pageIndex).origLink),
                                               subtitlePath : path(singleContentModel.get(pageIndex).origUrl)
                                           });*/
                        }
                        else {
                            //appWindow.showProgress(true);
                            //downloadManager.getVideoUrl(singleContentModel.get(pageIndex).origLink);
                            //Qt.openUrlExternally(streamingUrl(singleContentModel.get(pageIndex).origLink));
                            //console.log(streamingUrl(singleContentModel.get(pageIndex).origLink));

                            pageStack.push(Qt.resolvedUrl("Player.qml"), {
                                               url: streamingUrl(singleContentModel.get(pageIndex).origLink),
                                               subtitlePath : path(singleContentModel.get(pageIndex).origUrl)
                                           });


                        }
                    } else {
                        if (singleContentModel.get(pageIndex).status == 2) {


                            var filePath = downloadManager.getFullPath(singleContentModel.get(pageIndex).baseName);
                            pageStack.push(Qt.resolvedUrl("Player.qml"), {
                                               url: filePath,
                                               subtitlePath : path(singleContentModel.get(pageIndex).origUrl)
                                           });


                            //Qt.openUrlExternally(filename2);
                        } else {
                            console.log('Download is not finished yet.')
                        }
                    }
                }
            }

            Image {
                id: posterImageSmall
                source: singleContentModel.get(pageIndex).imageSmall
                smooth: true
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                visible: posterImage.status != Image.Ready
                onStatusChanged: {
                    if (posterImage.status == Image.Error) {
                    }
                }
            }

            Image {
                id: posterImage
                source: singleContentModel.get(pageIndex).imageBig
                smooth: true
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                onStatusChanged: {
                    if (posterImage.status == Image.Error) {
                    }
                }
            }

            Rectangle{
                id: pressedBox
                anchors.fill: parent
                color: "#ff2b06"
                visible: posterAreaMouse.pressed
                opacity: 0.2
            }

            Image {
                source: "image://theme/icon-l-common-video-playback"
                anchors.centerIn: parent
            }
        }

        Label {
            id: durationText
            text: singleContentModel.get(pageIndex).duration
            anchors { top: posterArea.bottom; left: posterArea.left  }
            anchors { topMargin: 2 }
            font.pixelSize: 18
        }

        Label {
            id: filesizeText
            text: (parseFloat(singleContentModel.get(pageIndex).mediaSize)/1048576).toFixed(2) + ' MB';
            anchors { top: posterArea.bottom; right: posterArea.right  }
            anchors { topMargin: 2 }
            font.pixelSize: 18
        }

        Flickable{
            id: textContainer

            clip : true

            anchors { top: appWindow.isLandscape ? posterArea.top : filesizeText.bottom; left: appWindow.isLandscape ?  posterArea.right : parent.left }

            height: parent.height
            contentHeight: subtitleText.height + dateText.height + summaryText.height + (appWindow.isLandscape ? 100 : 500)
            contentWidth: posterArea.width
            width: posterArea.width

            Label {
                id: subtitleText
                text: singleContentModel.get(pageIndex).subtitle
                anchors {left: parent.left; top: parent.top; right: parent.right}
                anchors { topMargin: 10; leftMargin: 12; rightMargin: 12 }
                wrapMode: Text.WordWrap
                font.pixelSize: 32
            }

            Label {
                id: dateText
                text: singleContentModel.get(pageIndex).pubDate.substring(0,singleContentModel.get(pageIndex).pubDate.indexOf('+'))
                anchors { top: subtitleText.bottom; left: parent.left; right: parent.right }
                anchors { topMargin: 4; leftMargin: 12; rightMargin: 12 }
                font.pixelSize: 18
            }

            Label {
                id: summaryText
                text: singleContentModel.get(pageIndex).summary
                anchors { top: dateText.bottom; left: parent.left; right: parent.right }
                anchors { topMargin: 20; leftMargin: 12; rightMargin: 12 }
                font.pixelSize: 22
            }
        }






        /*Item{

            Label {
                id: subtitleText
                text: singleContentModel.get(pageIndex).subtitle
                anchors { top: parent.top; left: posterArea.right; right: parent.right }
                anchors { topMargin: 12; leftMargin: 12; rightMargin: 12 }
                font.pixelSize: 32
            }

            Label {
                id: dateText
                text: singleContentModel.get(pageIndex).pubDate.substring(0,singleContentModel.get(pageIndex).pubDate.indexOf('+'))
                anchors { top: subtitleText.bottom; left: posterArea.right; right: parent.right }
                anchors { topMargin: 4; leftMargin: 12; rightMargin: 12 }
                font.pixelSize: 18
            }



            Label {
                id: summaryText
                text: singleContentModel.get(pageIndex).summary
                anchors { top: dateText.bottom; left: posterArea.right; right: parent.right }
                anchors { topMargin: 20; leftMargin: 12; rightMargin: 12 }
                font.pixelSize: 22
            }

        }*/


    }

    onStatusChanged: {

        if(status == PageStatus.Activating){

            if(downloadManager.exists(container.baseName(singleContentModel.get(pageIndex).origLink) + ".mp4")){
                searchIcon.visible = false;
            }else if(modelSource == 1){
                searchIcon.visible = true;
            }

        }


    }

    tools: ToolBarLayout{
        ToolIcon {
            iconId: "toolbar-back";
            anchors.left: parent.left
            onClicked: {
                pageStack.pop();
            }
        }

        ToolButtonRow {
            id: toolModeInfo
            visible: viewMode == 0
            anchors.centerIn: parent

            ToolIcon {
                id: searchIcon
                iconSource: "image://theme/icon-s-transfer-download"
                //visible: modelSource == 1
                onClicked: {
                    var object = JSON.parse(JSON.stringify(singleContentModel.get(pageIndex)));
                    object.status = 0;
                    object.baseName = singleContentModel.get(pageIndex).origLink.substring(singleContentModel.get(pageIndex).origLink.lastIndexOf('/')+1);
                    object.percentage = 0;
                    object.downloadUrl = '';
                    object.editMode = false;
                    object.downloadUrl = donwloadUrl(singleContentModel.get(pageIndex).origLink)

                    archivePage.download(object);
                }
            }

            ToolIcon {
                id: profileIcon
                iconId: "toolbar-share";
                onClicked: {
                    svc.share(singleContentModel.get(pageIndex).subtitle, singleContentModel.get(pageIndex).origUrl);
                }
            }
        }
    }

}
