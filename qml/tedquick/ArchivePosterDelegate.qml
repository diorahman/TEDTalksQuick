import QtQuick 1.1
import com.nokia.meego 1.0

Item{
    id: root

    signal clicked
    signal clickDelete
    signal editMode

    width: 200
    height: 150

    MouseArea{
        id: areaBox
        anchors.fill: parent
        onClicked: {
            if (model.editMode == false)
                root.clicked()
        }
        onPressAndHold: {
            root.editMode()
        }
    }

    Item {
        id: posterItem
        width: 200
        height: 150
        anchors.centerIn: parent
        scale: model.editMode ? 0.8 : 1

        Rectangle{
            id: backgroundBox
            anchors.fill: parent
            color: "#ff2b06"
            opacity: 0.2
        }

        Image {
            id: posterSmallImage
            source: model.imageSmall
            smooth: true
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            onStatusChanged: {
                if (posterImage.status == Image.Ready) {

                } else if (posterImage.status == Image.Error) {
                    console.log('error ' + posterImage.source);
                }
            }

            visible: posterImage.status != Image.Ready
        }

        Image {
            id: posterImage
            source: model.imageBig
            smooth: true
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            onStatusChanged: {
                if (posterImage.status == Image.Ready) {

                } else if (posterImage.status == Image.Error) {
                    console.log('error ' + posterImage.source);
                }
            }
        }

        Rectangle {
            id: titleRect
            anchors { left: parent.left; bottom:  parent.bottom; right:  parent.right}
            height: titleText.height + 14 + progressBar.height
            color: "black"
            opacity: 0.6
        }

        Label {
            id: titleText
            color: "white"
            text: model.subtitle
            font.pixelSize: 16
            anchors { bottom: progressBar.top; left: parent.left; right:  parent.right}
            anchors { bottomMargin: 2; leftMargin: 2; rightMargin: 2; }
        }

        ProgressBar {
            id: progressBar
            anchors { bottom: parent.bottom; left: parent.left; right:  parent.right}
            anchors { bottomMargin: 2; leftMargin: 2; rightMargin: 2; }
            visible: model.percentage < 100
            value: parseFloat(model.percentage)/100
        }

        Rectangle{
            id: pressedBox
            anchors.fill: parent
            color: "#ff2b06"
            visible: areaBox.pressed
            opacity: 0.2
        }

        Behavior on scale { PropertyAnimation { duration: 200 } }
    }


    Item {
        id: deleteButton
        visible: model.editMode
        width: 40
        height: 40
        anchors.right: parent.right
        anchors.top: parent.top

        MouseArea{
            id: deleteArea
            anchors.fill: parent
            onClicked: {
                root.clickDelete();
            }
        }

        Image {
            source: 'image://theme/icon-m-framework-close-thumbnail'
            width: 40
            height: 40
            anchors.centerIn: parent
            visible: !deleteArea.pressed
            smooth: true
        }

        Image {
            source: 'image://theme/icon-m-framework-close-thumbnail'
            width: 36
            height: 36
            anchors.centerIn: parent
            visible: deleteArea.pressed
            smooth: true
        }
    }



}
