import QtQuick 1.1
import com.nokia.meego 1.0

BasePage {
    id: container

    Item {
        anchors.fill: parent

        Image {
            id: logo
            source: "images/ted80.png"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: appWindow.isLandscape ? -140 : -60
            smooth: true
        }

        Label {
            id: appName
            text: "TEDTalks Quick"
            anchors.top: logo.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: desc
            text: "All contents belong to www.ted.com\nThis is an attempt to promote the spread of good ideas!"
            anchors.top: appName.bottom
            width: appWindow.isLandscape ? parent.width : 420
            wrapMode: Text.Wrap
            font.pixelSize: 20
            color: "darkgray"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10

        }

        Label {
            id: appVersion
            text: "v 0.2.50 | AegisLabs"
            anchors.top: desc.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button{
            id: appEmail
            anchors.top: appVersion.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Contact Us"
            width: 230
            onClicked: {
                Qt.openUrlExternally("mailto:apps@aegis.co.id");
            }
        }

        Button{
            id: appDonate
            anchors.top: appEmail.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            width: 230
            text: "Send Us Some ♥"
            onClicked: {
                Qt.openUrlExternally("http://aegis.no.de/ted/donate");
            }
        }

    }

    tools: commonTools
}

