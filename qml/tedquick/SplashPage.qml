import QtQuick 1.1

Rectangle {
    id: root

    property int timeout: 2000
    property int fadeout: 800

    signal finished

    function activate() {
        animation.start();
    }

    color: "#ffffff"

    Image {
        source: "images/tedlogo_text.png"
        smooth: true
        anchors.centerIn: parent
    }

    SequentialAnimation {
        id: animation

        PauseAnimation { duration: root.timeout }

        PropertyAnimation {
            target: splash
            properties: "opacity"
            duration: root.fadeout
            to: 0
        }

        ScriptAction { script: finished(); }
    }
}
