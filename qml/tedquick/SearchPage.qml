// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

BasePage {
    id: container
    property ListModel offlineModel: ListModel{}

    function search(phrase){
        phrase = phrase.trim();

        if(!phrase) return;

        var arr = phrase.split(" ");

        searchResult.clear();

        for(var j = 0; j < arr.length; j++){

            var w = arr[j].toLowerCase();

            for(var i = 0; i < offlineModel.count; i++){
                var obj = offlineModel.get(i);
                var t = obj.title.toLowerCase();
                var s = obj.summary.toLowerCase();

                if(t.indexOf(w) > -1 || s.indexOf(w) > -1){
                    searchResult.append(obj);
                }

            }
        }
    }

    TextField {
        id: field
        placeholderText: "Search"
        maximumLength: 20
        width: 350
        platformSipAttributes: sipAttributes
        inputMethodHints: Qt.ImhNoPredictiveText;

        anchors.horizontalCenter: parent.horizontalCenter

        Keys.onReturnPressed: {
                platformCloseSoftwareInputPanel()
                dummy.focus = true
                search(field.text);
        }

        onTextChanged: {

            if(field.text.length > 0)  searchIcon.source = "image://theme/icon-m-toolbar-close"
            search(field.text);
        }

        Image {
            id: searchIcon
            source:  field.text.length > 0 ? "image://theme/icon-m-toolbar-close" : "image://theme/icon-m-toolbar-search"
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter

            opacity: mouseAreaClose.pressed ? 0.5 : 1.0
        }

        MouseArea{
            id: mouseAreaClose
            anchors.fill: searchIcon
            onClicked: {

                if(field.text.length > 0){
                    field.text = "";
                    searchIcon.source = "image://theme/icon-m-toolbar-search"
                    searchResult.clear();
                }

            }

        }
    }

    Item { id: dummy }

    SipAttributes {
         id: sipAttributes
         actionKeyLabel: "Close"
         actionKeyHighlighted: true
         actionKeyEnabled: true
     }


    ListModel{
        id: searchResult
    }

    GridView {
        clip: true
        cellHeight: 160
        cellWidth: 206
        model: searchResult
        anchors.top: field.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.leftMargin: appWindow.isLandscape ? 18 : 40
        anchors.topMargin: 20
        anchors.bottom: parent.bottom
        delegate: PosterSmallDelegate {
            onClicked: {
                pageStack.push(Qt.resolvedUrl("VideoPage.qml"), {
                                   pageIndex: index,
                                   singleContentModel: searchResult,
                                   modelSource:1
                               });
            }
        }
    }

    /*ListView{
        id: searchResultListView
        model: searchResult
        anchors.top: field.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        delegate:
            Item{
                width: ListView.view.width
                height: 100

                Text{
                    id: titleText
                    anchors.fill: parent
                    text: model.subtitle
                }

            }

    }*/

    Text {
        anchors.centerIn: parent
        visible: searchResult.count == 0
        text: '"Search your favorite talks"'
        font.pixelSize: 42
        horizontalAlignment: Text.AlignHCenter

        wrapMode: Text.WordWrap
        width: parent.width - 100

        color: "gray"
    }

    tools: ToolBarLayout{
            ToolIcon{
                iconId: "toolbar-back"
                anchors.left: parent.left

                onClicked: {
                    pageStack.pop();
                }
            }
    }


    Component.onCompleted: {}
}
