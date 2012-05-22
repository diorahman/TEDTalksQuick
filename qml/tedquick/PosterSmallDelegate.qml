import QtQuick 1.1
import com.nokia.meego 1.0

Item{
    id: root

    signal clicked

    width: 200
    height: 150

    MouseArea{
        id: areaBox
        anchors.fill: parent
        onClicked: {
            root.clicked()
        }
    }

    Rectangle{
        id: backgroundBox
        anchors.fill: parent
        color: "#ff2b06"
        opacity: 0.2
    }

    Image {
        id: posterImageSmall
        source: model.imageSmall
        smooth: true
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        onStatusChanged: {
            if (posterImageSmall.status == Image.Ready) {

            } else if (posterImageSmall.status == Image.Error) {
                console.log('error ' + posterImageSmall.source);
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
        height: titleText.height + 10
        color: "black"
        opacity: 0.6
    }

    Label {
        id: titleText
        color: "white"
        text: model.subtitle
        font.pixelSize: 16
        anchors { verticalCenter: titleRect.verticalCenter; left: parent.left; right:  parent.right}
        anchors { leftMargin: 2; rightMargin: 2; }
    }

    Rectangle{
        id: pressedBox
        anchors.fill: parent
        color: "#ff2b06"
        visible: areaBox.pressed
        opacity: 0.2
    }

}
