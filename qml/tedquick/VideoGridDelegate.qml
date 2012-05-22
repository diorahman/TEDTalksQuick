import QtQuick 1.1

Item {
    id: root

    width: ListView.view.width
    height: ListView.view.height

    signal clicked(int index)

    Item {
        id: mainView
        visible: index == 0
        anchors.fill: parent
        anchors.margins: 10

        PosterBigDelegate {
            id: featured
            anchors {
                top: parent.top
                left: parent.left
                topMargin: appWindow.isLandscape ? 0 : 40
                leftMargin: appWindow.isLandscape ? 0 : 40
            }

            imageSource: mainPage.model.get(model.startIndex).imageBig
            imageSmallSource: mainPage.model.get(model.startIndex).imageSmall
            title: mainPage.model.get(model.startIndex).subtitle
            onClicked: {
                root.clicked(model.startIndex);
            }
        }

        GridView {
            id: gridPosters
            anchors {
                top: appWindow.isLandscape ? parent.top : featured.bottom;
                left: appWindow.isLandscape ? featured.right : featured.left;
                right: parent.right;
                bottom: parent.bottom
            }

            anchors {
                topMargin: appWindow.isLandscape ? 0 : 6
                leftMargin: appWindow.isLandscape ? 6 : 0
            }
            clip: true
            cellHeight: 156
            cellWidth: 206
            model: gridModel
            interactive : false
            delegate: PosterSmallDelegate {
                onClicked: {
                    root.clicked(index + 1);
                }
            }
        }

    }

    Item {
        id: nextView
        visible: index != 0

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: appWindow.isLandscape ? 12 : 50
            leftMargin: appWindow.isLandscape ? 12 : 40
        }

        GridView {
            anchors.fill: parent

            interactive: false
            clip: true
            cellHeight: 156
            cellWidth: 206
            model: gridModel
            delegate: PosterSmallDelegate {
                onClicked: {
                    root.clicked(startIndex + index);
                }
            }
        }
    }


    ListModel {
        id: gridModel
    }

    Component.onCompleted: {
        //console.log(index + ' start index ' + model.startIndex);
        var start = index == 0 ? model.startIndex + 1 : model.startIndex;
        gridModel.clear();
        for (var i = start; i < model.endIndex; i++) {
            gridModel.append(JSON.parse(JSON.stringify(mainPage.model.get(i))));
        }
    }
}

