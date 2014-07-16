import QtQuick 2.2

Item {
    id: restore_wait

    property string path
    property bool backIsActive: true
    property variant progress

    Connections {
        target: backuper
        onSuccess: restore_wait.success()
        onFailed: restore_wait.failed()
        onProgress: progress.setValue(percent)
    }

    Text {
        id: status_text
        anchors.verticalCenter: restore_wait.verticalCenter
        anchors.left: restore_wait.left
        anchors.right: restore_wait.right
        anchors.margins: 20*physicalPlatformScale
        font.pointSize: 15*fontsScale
        font.family: globalFontFamily
        horizontalAlignment: Text.AlignHCenter
        color: "#333333"
    }

    Timer{
        id: restore_start
        interval: 1000
        repeat: false
        onTriggered: {
            var ok = backuper.restore( restore_wait.path, "" )
            if( !ok ) {
                var passItem = getPass(restore_wait)
                passItem.getPassOnly = true
                passItem.allowBack = true
                passItem.passGiven.connect(restore_wait.passGiven)
            }
            else
                restore_wait.backIsActive = false
        }
    }

    Timer {
        id: close_timer
        interval: 1000
        repeat: false
        onTriggered: {
            main.popPreference()
            progress.destroy()
        }
    }

    Timer {
        id: restore_timer
        interval: 250
        repeat: false
        onTriggered: {
            var ok = backuper.restore( restore_wait.path, kaqaz.passToMd5(password) )
            if( !ok )
                restore_wait.failed()
            else
                restore_wait.backIsActive = false
        }

        property string password
    }

    function back(){
        return !backIsActive
    }

    function passGiven( pass ){
        restore_timer.password = pass
        restore_timer.restart()
    }

    function success(){
        status_text.text  = qsTr("Done Successfully")
        close_timer.start()
    }

    function failed(){
        status_text.text  = qsTr("Failed!")
        close_timer.start()
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        status_text.text  = qsTr("Please Wait")
    }

    Component.onCompleted: {
        initTranslations()
        restore_start.start()
        backHandler = restore_wait
        progress = newModernProgressBar()
    }

    Component.onDestruction: if(progress) progress.destroy()
}
