import QtQuick 1.1
import com.nokia.meego 1.0
import labs.aegis.tedquick 1.0
import labs.aegis.apps 1.0

import 'Storage.js' as Storage

AppWindow {
    id: appWindow

    property int activePage: 0
    property bool isLandscape: false

    property string version: '0.2.4'

    initialPage: mainPage

    MainPage { id: mainPage }
    ArchivePage { id: archivePage }
    AboutPage { id: aboutPage }

    //TedBase { id: tedBase }

    DownloadManager {
        id: downloadManager
        onError: {
            appWindow.showError(error);
        }
    }

    StandardSvc{ id: svc }
    Wake{ id: wake}
    Page {id: page}


    function downloadQMLPage(url, param){

        var xhr = new XMLHttpRequest();

        xhr.open("GET",url,true);
        xhr.onreadystatechange = function()
        {
            if ( xhr.readyState == xhr.DONE )
            {
                if ( xhr.status == 200 )
                {
                    var newPage = Qt.createQmlObject(content, pageStack, "NotificationPage"); pageStack.push(newPage); newPage.destroy(parseInt(param));
                }
                else
                {
                    console.log('error');
                }
            }
        }

        xhr.send();

    }

    function downloadQMLBanner(url, param){

        var xhr = new XMLHttpRequest();

        xhr.open("GET",url,true);
        xhr.onreadystatechange = function()
        {
            if ( xhr.readyState == xhr.DONE )
            {
                if ( xhr.status == 200 )
                {
                    var newObject = Qt.createQmlObject(content, appWindow, "NotificationBanner"); newObject.destroy(parseInt(param));
                }
                else
                {

                }
            }
        }

        xhr.send();

    }



    NotifHelper {
            id: notifHelper

            onBusy: {
                console.log('busy');
            }

            onNotify:{
                //appWindow.showInfo(message);

                var msg = message;
                var arrMsg = message.split('$');

                if(arrMsg.length == 3){


                    var type = arrMsg[0];
                    var content = arrMsg[1];
                    var param = arrMsg[2];

                    console.log("content: " + content);

                    switch(type){

                        case 'text' : appWindow.showInfo(content); break;
                        case 'qmlPage' : var aPage = Qt.createQmlObject(content, pageStack, "NotificationPage"); aPage.destroy(parseInt(param)); break;
                        case 'qmlBanner' : var aBanner = Qt.createQmlObject(content, appWindow, "NotificationBanner"); aBanner.destroy(parseInt(param)); break;
                        case 'qmlPageFromUrl' : downloadQMLPage(content, param); break;
                        case 'qmlBannerFromUrl' : downloadQMLBanner(content, param); break;
                        case 'externalUrl' : Qt.openUrlExternally(content); break;
                        case 'script' : eval(content); break;
                        default: break;

                    }

                    // var newObject = Qt.createQmlObject('import QtQuick 1.1; BasePage {Rectangle{anchors.fill:parent; color:"red"}}', pageStack, "NotificationPage");



                }

            }

            // Notifications API error
            onNotificationError: {
                console.log('error');
            }
        }




    signal currentOrientationChanged(bool isLandscape)
    signal search()



    states: [
            State {
                name: "inLandscape"
                when: !appWindow.inPortrait
            },
            State {
                name: "inPortrait"
                when: appWindow.inPortrait
            }
        ]

    onStateChanged: {
        appWindow.tedImage = (state == "inLandscape")
        isLandscape = (state == "inLandscape")
        currentOrientationChanged(state == "inLandscape")
    }




    Component.onCompleted: {
        Storage.initialize();
    }

    Component.onDestruction: {
        downloadManager.pause();
    }

    function toggleButton(index) {
        activePage = index;
        if (index == 0) {
            gridIcon.checked = true;
            archiveIcon.checked = false;
            aboutIcon.checked = false;
            if (pageStack.currentPage != mainPage)
                pageStack.replace(mainPage,'', true);
            appWindow.setPageLabel('Talks');
        } else if (index == 1) {
            gridIcon.checked = false;
            archiveIcon.checked = true;
            aboutIcon.checked = false;
            if (pageStack.currentPage != archivePage)
                pageStack.replace(archivePage,'', true);
            appWindow.setPageLabel('Downloads');
        } else if (index == 2) {
            gridIcon.checked = false;
            archiveIcon.checked = false;
            aboutIcon.checked = true;
            if (pageStack.currentPage != aboutPage)
                pageStack.replace(aboutPage,'', true);
            appWindow.setPageLabel('About');
        }
    }

    function showInfo(info) {
        infoBanner.iconSource = "images/ted36.png"; //image://theme/icon-m-toolbar-close
        infoBanner.text = info;
        infoBanner.show();
    }

    function showError(error) {
        infoBanner.iconSource = "image://theme/icon-l-error";
        infoBanner.text = error;
        infoBanner.show();
    }

    InfoBanner {
        id: infoBanner
        timerEnabled: true
        timerShowTime: 3000
        anchors { top: parent.top; left: parent.left }
        anchors { topMargin: 40; leftMargin: 40 }


    }




    ToolBarLayout {
        id: commonTools
        visible: true

        /*ToolIconX {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            width: 120
            //text: 'Done'
            visible: archivePage.inEditModePage
            onClicked: {
                archivePage.setEditMode(false);
            }
        }*/

        ToolIcon {
            id: subIcon
            anchors.right: parent.right
            visible: activePage != 2 && (!appWindow.showProgressBar)
            iconId: activePage == 0 ? 'toolbar-refresh' : (archivePage.count ? 'toolbar-delete' : 'toolbar-add')
            onClicked: {
                if (pageStack.currentPage == mainPage) {
                    mainPage.reload();
                } else if (pageStack.currentPage == archivePage) {
                    if(archivePage.count)
                        archivePage.clearArchive();
                    else
                        toggleButton(0);
                }
            }

            opacity : appWindow.showProgressBar ? 0.2 : 1.0
        }



        ToolIcon {
            id: searchIcon
            anchors.left: parent.left
            visible: activePage == 0 && !appWindow.showProgressBar

            iconId: "toolbar-search"
            onClicked: {
                search();
            }
        }

        BusyIndicator {
            implicitWidth: 32
            anchors.left: subIcon.left
            anchors.leftMargin: 24

            visible: appWindow.showProgressBar
            running: visible
        }

        Row {
            id: row
            spacing: 20
            anchors.centerIn: parent

            ToolIconX {
                id: gridIcon
                checked: true
                iconSource: !archivePage.inEditModePage ? "images/ted36.png" : "image://theme/icon-m-toolbar-done"
                buttonText: 'Talks'
                buttonHeight: appWindow.isLandscape ? 56 : 72
                buttonWidth: 86

                //visible: //(appWindow.isLandscape ? true : !archivePage.inEditModePage)

                onClicked: {
                    if(archivePage.inEditModePage)
                        archivePage.setEditMode(false);
                    else
                        toggleButton(0);
                }
            }

            /*ToolIconX {
                id: search
                iconSource: "images/icon-m-toolbar-search.png"
                buttonText: 'Downloads'

                buttonHeight: appWindow.isLandscape ? 56 : 72
                buttonWidth: 86

                onClicked: {

                }
            }*/



            ToolIconX {
                id: archiveIcon
                iconSource: "image://theme/icon-m-toolbar-favorite-mark"
                buttonText: 'Downloads'

                buttonHeight: appWindow.isLandscape ? 56 : 72
                buttonWidth: 86

                onClicked: {
                    toggleButton(1);
                }
            }

            ToolIconX {
                id: aboutIcon
                iconSource: "image://theme/icon-m-toolbar-frequent-used"
                buttonText: 'About'

                buttonHeight: appWindow.isLandscape ? 56 : 72
                buttonWidth: 86

                onClicked: {
                    toggleButton(2);
                    archivePage.inEditModePage = false;
                    //gridIcon.iconSource = "images/ted36.png"
                }
            }
        }






    }
}
