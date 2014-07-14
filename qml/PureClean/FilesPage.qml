import QtQuick 1.1
import com.nokia.symbian 1.1
import App 1.0
Page {
    id: root
    property bool editMode: true
    property int itemIndex: -1;
    property alias model: flick.model;
    signal fileUpdated(string fileName)
    property int selIndex:-1;
    QueryDialog{
        id: delDial;
        property int delIndex: -1
        message: qsTr("Точно удалить, без возможности воостановления?")
        titleText: qsTr("Удалить?")
        acceptButtonText: qsTr("OK");
        height: 200;
        rejectButtonText: qsTr("Отмена")
        onAccepted: {
            application.removeFile(delIndex,itemIndex);
        }
    }
    function openFile( dirMode ) {
                var component = Qt.createComponent("FileDialog.qml");
                var dialog = component.createObject(root);
                if( dialog !== null ) {
                    if( dirMode) {
                        dialog.dirMode = true;
                    }
                    dialog.fileSelected.connect(fileSelected);
                    dialog.directorySelected.connect(directorySelected);
                    dialog.open();
                }
            }

            function fileSelected( filePath ) {
                console.debug("bookAdded:" + filePath);
                fileUpdated(filePath);
            }

            function directorySelected( dirPath) {
                console.debug("directoryAdded:" + dirPath);
            }

    Text {
            id: header
            visible: true;
            text: qsTr("Список файлов:")
            color:"white"
            font.pixelSize: 16;
            horizontalAlignment: Text.AlignJustify
            wrapMode: Text.WordWrap;
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 5;
            anchors.rightMargin: 5;
            anchors.top: parent.top;
            anchors.topMargin: 5;

        }
    ListView{
        id:flick
        visible:true;
        anchors.top: header.bottom;
        anchors.bottom: addButton.top
        anchors.bottomMargin: 5
        anchors.topMargin: 5;
        anchors.left: parent.left;
        anchors.right: parent.right
        //contentWidth: parent.width;
        //contentHeight: c.height+20
        flickableDirection: Flickable.VerticalFlick
        clip: true
                model: application.filesModel
                delegate: Component{
                    Item{
                        Connections{
                            target: root
                            onFileUpdated: {
                                application.setFile(root.selIndex,itemIndex,fileName.replace("file:///","").replace("//","/"));
                                application.updateFiles();
                            }
                        }

                        id:delegate
                        width: flick.width
                        height: Math.max(sw.height,apptxt.height);
                        Item {
                            id: apptxt
                            anchors.left: parent.left
                            anchors.right: sw.left
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10;
                            anchors.verticalCenter: sw.verticalCenter
                            height: apptxt2.height
                            TextField{
                                id: apptxt2
                                visible: root.editMode;
                                anchors.left: parent.left
                                anchors.right: parent.right
                                text: modelData
                                onTextChanged: {application.setFile(index,itemIndex,text);}
                                //onActiveFocusChanged:
                            }

                        }
                        Item{
                            id:sw
                            property int click: 0
                            anchors.right: parent.right
                            anchors.rightMargin: 10;
                            anchors.verticalCenter: parent.verticalCenter
                            height: sw2.height;
                            width: root.editMode?sw2.width+sw3.width:sw1.width;
                            Button{
                                id: sw2
                                text:"X";
                                anchors.right: parent.right
                                anchors.rightMargin: sw3.width+5
                                visible: root.editMode;
                                onClicked: {delDial.delIndex=index; delDial.open();}
                            }
                            Button{
                                id: sw3
                                text:"...";
                                anchors.right: parent.right
                                visible: root.editMode;
                                onClicked: {root.selIndex=index; root.openFile(false);}
                            }

                        }
                    }
                }
            }
    ScrollBar {
        flickableItem: flick
        anchors { right: flick.right; top: flick.top; topMargin: 5; }
        interactive: true;
        policy: Symbian.ScrollBarWhenNeeded
    }
    Button{
        id: addButton;
        anchors.left: parent.left
        anchors.leftMargin: 10;
        width: parent.width/2-20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5;
        height: root.editMode?50:0;
        text: "+1"
        onClicked: {application.addFile(itemIndex,"C:\\1.txt");flick.positionViewAtEnd ();}
    }
    Button{
        id: addButton2;
        anchors.right: parent.right
        anchors.rightMargin: 10;
        width: parent.width/2-20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5;
        height: root.editMode?50:0;
        text: "+ много"
        onClicked: {root.pageStack.push(Qt.resolvedUrl("LongTextPage.qml"));flick.positionViewAtEnd();}
    }
}
