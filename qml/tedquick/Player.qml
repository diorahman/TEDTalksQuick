// import QtQuick 1.1 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import QtMultimediaKit 1.1
import "ModelRequest.js" as Request

BasePage{

    id: player

    property string url : ""
    property string subtitlePath: ""
    property bool showToolBar: false
    property string videoId : ""

    property int introDuration : 0
    property int adDuration : 0
    property int postAdDuration : 0

    property int lastIndex : 0

    property bool isWake: false


    /*function land(){
        appWindow.fullScreen(true);
    }

    function pot(){
        appWindow.fullScreen(false);
    }*/

    Item {
        id: requestItem

        function started() {
            appWindow.showProgress(true);
        }

        function ended(jsonObject, name) {
            console.log(JSON.stringify(jsonObject));


            appWindow.showProgress(false);


            if(name == "path"){

                subtitleModel.clear();

                player.videoId = jsonObject.id.substring(1, jsonObject.id.length - 1);
                player.introDuration =  parseInt(jsonObject.introDuration.substring(1, jsonObject.introDuration.length - 1));
                player.adDuration =  parseInt(jsonObject.adDuration.substring(1, jsonObject.adDuration.length - 1));
                player.postAdDuration =  parseInt(jsonObject.postAdDuration.substring(1, jsonObject.postAdDuration.length - 1));


                subtitleModel.append({name : "None", code: "none"});

                for(var i = 0; i < jsonObject.languages.length; i++){
                    subtitleModel.append({name : jsonObject.languages[i].Name, code: jsonObject.languages[i].LanguageCode});
                    subtitleModelData.append(jsonObject.languages[i]);
                    console.log(jsonObject.languages[i].Name);
                }

                optButton.visible = true;



            }else{

                optButton.enabled = true;

                subtitleModelScript.clear();

                for(var i = 0; i < jsonObject.captions.length; i++){
                    subtitleModelScript.append(jsonObject.captions[i]);
                }
            }



        }

        function error() {

            subtitleModel.clear();
            subtitleModel.append({name : "None", code: "none"});

            optButton.enabled = true;
            optButton.visible = true;

            //optButton.visible = true
        }
    }

    Video {
        id: video
        x: 0
        y: 0
        width: appWindow.isLandscape ? 854 : 480
        height: appWindow.isLandscape ? 480 : 270
        fillMode: Video.PreserveAspectFit

        source: url

        focus: true

        MouseArea{
            id: mouseArea
            anchors.fill: parent

            onClicked: {
                if (appWindow.isLandscape)
                toolbar.visible = !toolbar.visible
            }
        }

        onPositionChanged: {

            //subtitleLabel.text = position;
            //console.log(position);
            //console.log(introDuration);

            for(var i = player.lastIndex; i < subtitleModelScript.count; i++){
                var obj = subtitleModelScript.get(i);
                var startTime = obj.startTime + adDuration + postAdDuration + 11000;

                if(startTime <= position && startTime + obj.duration > position){
                    subtitleLabel.text = obj.content
                    player.lastIndex = i;
                    break;
                }
            }

        }

        onBufferProgressChanged: {
            //console.log(bufferProgress);

        }

        onHasVideoChanged: {
            if(video.hasVideo){
                progressBar2.visible = true;
                progressBar.visible = true;
            }
        }


    }




    /*Item{
        id: box
        //color: 'red'
        anchors.centerIn: parent
        width: progressBar.width + 100
        height: progressBar.height + 100

    }*/

    ListModel {
        id: subtitleModel
    }

    ListModel {
        id: subtitleModelData
    }

    ListModel {
        id: subtitleModelScript
    }



    // Create a selection dialog with a title and list elements to choose from.
     SelectionDialog {
         id: subtitlesDialog
         titleText: "Available Subtitles"
         selectedIndex : 0
         model: subtitleModel

         onAccepted: {
             console.log(selectedIndex);
             if(selectedIndex){
                 Request.fetch({id : player.videoId, code : subtitleModel.get(selectedIndex).code}, "script")
                 optButton.enabled = false;
                 subtitleLabel.text = "";
                 textBox.visible = true;

             }else{
                textBox.visible = false
                 subtitleLabel.text = "";
             }

             video.play()

         }

         onRejected: {
            console.log(selectedIndex);

             video.play()
         }
     }


     /*Rectangle{
         id: textBox
         anchors.centerIn: parent
         width: parent.width - 50
         height: subtitleLabel.height

     }*/

    Rectangle{
        id: toolbar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: appWindow.isLandscape ? 60 : parent.height - video.height

        visible: appWindow.isLandscape ? visible : true


        MouseArea{
            anchors.fill: parent
        }

        ToolIcon {
            iconId: "toolbar-previous";
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            //anchors.verticalCenter: appWindow.isLandscape ? parent.verticalCenter : undefined

            onClicked: {
                pageStack.pop();
            }
        }

        Image {
            id: imageLamp
            source: "images/lamp-black.png"
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.rightMargin: 15
            visible: false
        }

        Timer{
            id: wakeTimer
            repeat: false
            interval: 100
            onTriggered:{

                if(!wake.getScreenSaverStatus()){
                    wake.setScreenSaverInhibit(true);
                }
            }
        }

        ProgressBar {
                id: progressBar2
                width: 300
                minimumValue: 0
                maximumValue: 300
                value: video.bufferProgress * 300
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 30 - (progressBar2.height/2)
                anchors.leftMargin: parent.width/2 - (progressBar2.width/2)


                opacity: 0.5
                visible : false
                platformStyle: ProgressBarStyle
                {

                }
        }

        ProgressBar {
                id: progressBar
                width: 300
                minimumValue: 0
                maximumValue: 300
                value: rect.x
                anchors.horizontalCenter: progressBar2.horizontalCenter
                anchors.verticalCenter: progressBar2.verticalCenter

                visible : false

                indeterminate: (video.bufferProgress == 0)

                Item {
                         id: rect
                         width: progressBar.height- 4; height: progressBar.height -4
                         anchors.verticalCenter: progressBar.verticalCenter
                         opacity: (600.0 - rect.x) / 600
                         x : (video.position * 300.0/video.duration)

                }
        }

        ToolIcon {
            id: playButton
            iconId: video.bufferProgress ? (video.paused? "toolbar-mediacontrol-play" :"toolbar-mediacontrol-pause") : "toolbar-mediacontrol-play" ;
            anchors.right: progressBar2.left
            anchors.verticalCenter: progressBar2.verticalCenter
            anchors.rightMargin: 10
            visible: progressBar2.visible
            opacity: video.bufferProgress ? 1.0 : 0.8
            onClicked: {

                console.log("video playing?: " + video.playing);

                //pageStack.pop();
                //if(video.bufferProgress){
                    if(iconId == "toolbar-mediacontrol-pause"){
                        video.pause();
                        iconId = "toolbar-mediacontrol-play"
                        console.log('pause');
                    }else{
                        video.play();
                        iconId = "toolbar-mediacontrol-pause"
                        console.log('play');
                        console.log(video.seekable);
                    }
                //}
            }
        }

        ToolIcon {
            id: optButton
            iconId: "toolbar-new-message";
            anchors.left: progressBar2.right
            anchors.verticalCenter: progressBar2.verticalCenter
            anchors.leftMargin: 10
            visible: false //progressBar2.visible && (subtitleModel.count > 0)
            opacity: video.bufferProgress ? 1.0 : 0.8
            onClicked: {
                video.pause()
                subtitlesDialog.open();
            }
        }
    }

    BusyIndicator{
        id: busy
        running: visible
        visible: !video.hasVideo || appWindow.showProgressBar
        anchors.centerIn: parent

    }

    Connections{
        target : appWindow
        onCurrentOrientationChanged: {
            if(!isLandscape) toolbar.visible = true;
        }
    }

    Rectangle{
        id: textBox
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: appWindow.isLandscape ? (toolbar.visible? toolbar.height : 0 ) : (toolbar.height/2 + (toolbar.height/2 - (subtitleLabel.height + 80)))

        height: subtitleLabel.height + 10
        opacity: 0.8

    }

    Text {
        id: subtitleLabel
        font.pixelSize: appWindow.isLandscape ? 28 : 38
        wrapMode: Text.WordWrap
        anchors.horizontalCenter: textBox.horizontalCenter
        anchors.bottom: textBox.bottom
        anchors.bottomMargin: appWindow.isLandscape ? 5 : 10
        width: textBox.width - 100
        text: ""

    }

    tools: null //appWindow.isLandscape ? null : commonTools


    onStatusChanged: {
        if(status == PageStatus.Active){
            appWindow.fullScreen(true);
            Request.setItem(requestItem);
            Request.fetch(subtitlePath, "path");
            toolbar.visible = true;
            textBox.visible = false
             subtitleLabel.text = "";

            video.play();

            wakeTimer.start();


        }else if(status == PageStatus.Activating){
            commonTools.visible = false;
        }
        else if(status == PageStatus.Deactivating){

            appWindow.fullScreen(false);
            video.stop();
            video.source = "";
            Request.abort();
            appWindow.showProgress(false);

            wakeTimer.stop();
            video.stop()

            if(wake.getScreenSaverStatus()){
                wake.setScreenSaverInhibit(false);
                //wake.setValue(3);
            }
        }
    }

}


