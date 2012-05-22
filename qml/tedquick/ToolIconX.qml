
import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: root

    property bool checked: false
    property url iconSource
    property string buttonText: ''
    property string pressedBackground: "images/navigationbar.png"
    property alias buttonHeight : name.height
    property alias buttonWidth : name.width

    signal clicked

    width: 86; height: 58

    BorderImage {
        id: name
        source: mouseArea.pressed || checked ? root.pressedBackground : ""
        anchors.centerIn: parent
        width: 86; height: 58
        border.left: 5; border.top: 5
        border.right: 5; border.bottom: 5

        Image {
            id: imageButton
            source: iconSource
            anchors.centerIn: parent
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            parent.clicked();
        }
    }
}
