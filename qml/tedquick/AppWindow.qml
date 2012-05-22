import QtQuick 1.1
import com.nokia.meego 1.0

Window {
    id: window

    property bool showStatusBar: false
    property bool showToolBar: true
    property bool showProgressBar: false
    property variant initialPage
    property alias pageStack: stack
    property Style platformStyle: PageStackWindowStyle{}

    property bool tedImage: false
    property alias showTitleBar: titleBar.visible

    //Deprecated, TODO Remove this on w13
    property alias style: window.platformStyle

    function showProgress(show) {
        showProgressBar = show;
    }

    function setPageLabel(label) {
        // pageLabel.text = label;
    }

    function fullScreen(full){

        contentArea.anchors.top = full ? appWindowContent.top : titleBar.bottom
        titleBar.visible = !full
        //statusBar.showStatusBar = !full
    }

    objectName: "pageStackWindow"

    StatusBar {
        id: statusBar
        anchors.top: parent.top
        width: parent.width
        showStatusBar: window.showStatusBar
    }

    onOrientationChangeStarted: {
        statusBar.orientation = screen.currentOrientation
    }

    Image {
        id: backgroundImage
        source: "images/applicationpage-background.jpg"
        fillMode: Image.Stretch
        width: window.inPortrait ? screen.displayHeight : screen.displayWidth
        height: window.inPortrait ? screen.displayWidth : screen.displayHeight
        anchors { top: parent.top; left: parent.left; }
    }

    Item {
        id: appWindowContent
        objectName: "appWindowContent"
        width: parent.width
        anchors.top: statusBar.bottom
        anchors.bottom: parent.bottom

        // content area
        Item {
            id: contentArea
            anchors { top: titleBar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; }
            anchors.bottomMargin: toolBar.visible || (toolBar.opacity==1)? toolBar.height : 0
            PageStack {
                id: stack
                anchors.fill: parent
                toolBar: toolBar
            }
        }

        Rectangle {
            id: titleBar
            anchors { top: parent.top; left: parent.left; right: parent.right; }
            height: 50
            color: '#f0f1f3'

            Image {
                id: tedLogo
                source: "images/tedlogo.png"
                anchors { left: parent.left; top: parent.top; }
                anchors { leftMargin: 10; topMargin: 10;}
                smooth: true
                height: 40
                fillMode: Image.PreserveAspectFit

                visible: tedImage
            }


            /*Label {
                id: tedLabel
                text: 'Ideas worth spreading'
                anchors { right: parent.right; bottom: parent.bottom; }
                anchors { rightMargin: 20; bottomMargin: 4; }
                font.pixelSize: 24
            }

            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right; }
                anchors { bottomMargin: 2;}
                height: 2
                color: "#ff2b06"
            }*/
        }

        Item {
            id: roundedCorners
            visible: platformStyle.cornersVisible
            anchors { top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom; }
            z: 10001

            Image {
                anchors.top : parent.top
                anchors.left: parent.left
                source: "image://theme/meegotouch-applicationwindow-corner-top-left"
            }
            Image {
                anchors.top: parent.top
                anchors.right: parent.right
                source: "image://theme/meegotouch-applicationwindow-corner-top-right"
            }
            Image {
                anchors.bottom : parent.bottom
                anchors.left: parent.left
                source: "image://theme/meegotouch-applicationwindow-corner-bottom-left"
            }
            Image {
                anchors.bottom : parent.bottom
                anchors.right: parent.right
                source: "image://theme/meegotouch-applicationwindow-corner-bottom-right"
            }
        }

        /*
        // progress bar area
        Rectangle {
            id: progressBarArea
            anchors { top: parent.top; left: parent.left; right: parent.right}
            height: 4
            color: "black"

            Rectangle {
                visible: showProgressBar
                id: innerRect
                color: "#ff2b06"
                width: 20
                height: 4
                radius: 1
                anchors.verticalCenter: parent.verticalCenter

                SequentialAnimation on x {
                    running: visible
                    loops: Animation.Infinite
                    NumberAnimation {
                        to: progressBarArea.width - 20
                        duration: 1000
                    }
                    NumberAnimation {
                        to: 0
                        duration: 1000
                    }
                }
            }
        }
        */

        ToolBar {
            id: toolBar
            anchors.bottom: parent.bottom
            privateVisibility: (inputContext.softwareInputPanelVisible==true || inputContext.customSoftwareInputPanelVisible == true)
                               ? ToolBarVisibility.HiddenImmediately : (window.showToolBar ? ToolBarVisibility.Visible : ToolBarVisibility.Hidden)
        }

        SplashPage {
            id: splash
            anchors.fill: parent
            timeout: 2000
            fadeout: 1800
            Component.onCompleted: splash.activate();
            onFinished: {
                splash.destroy();
            }
        }

    }

    // event preventer when page transition is active
    MouseArea {
        anchors.fill: parent
        enabled: pageStack.busy
    }

    Component.onCompleted: {
        if (initialPage) pageStack.push(initialPage);
    }

}
