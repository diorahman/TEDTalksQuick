import QtQuick 1.1

Item {
    id: root

    width: ListView.view.width
    height: ListView.view.height

    signal clicked(int index)
    signal deleteItem(int index);
    signal inEditMode

    property int percentage: 0
    property int activeIndex: 0

    Connections {
        target: archivePage
        onInEditModePageChanged: {
            if (archivePage.inEditModePage == false) {
                for (var i = 0; i < gridModel.count; i++) {
                    gridModel.setProperty(i, 'editMode', false);
                }
            }
        }
    }

    Item {
        id: nextView
        anchors.fill: parent
        anchors.margins: 12

        GridView {
            anchors.fill: parent
            clip: true
            cellHeight: 160
            cellWidth: 206
            model: gridModel
            delegate: ArchivePosterDelegate {
                onClicked: {
                    //console.log(startIndex + ' ' + index);
                    root.clicked(startIndex + index);
                }
                onEditMode: {
                    root.inEditMode();
                    for (var i = 0; i < gridModel.count; i++) {
                        gridModel.setProperty(i, 'editMode', true);
                    }
                }
                onClickDelete: {
                    root.deleteItem(startIndex + index);
                }
            }
        }
    }

    ListModel { id: gridModel }

    onPercentageChanged: {
        //console.log('grid %: ' + activeIndex + ' ' + percentage);

        var aGridModel = gridModel.get(activeIndex);

        //if(aGridModel){
            aGridModel.percentage = percentage;
            gridModel.set(activeIndex, aGridModel);
        //}


        //gridModel.get(activeIndex).percentage = percentage;
    }

    Component.onCompleted: {
        //console.log(index + ' start index ' + model.startIndex);
        gridModel.clear();
        for (var i = model.startIndex; i < model.endIndex; i++) {
            gridModel.append(JSON.parse(JSON.stringify(archivePage.model.get(i))));
        }
    }
}

