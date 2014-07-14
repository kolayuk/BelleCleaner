import QtQuick 1.1
import com.nokia.symbian 1.1
import App 1.0
import QtMobility.systeminfo 1.2

Page {
    id: root
    property bool editMode: false
    OkDialog{
        id:rootDialog;
        helpText: "Для работы программы нужен полный доступ!"
        onAccepted:Qt.quit();
        onClickedOutside: Qt.quit();
        onRejected: Qt.quit();
    }
    QueryDialog{
        id: delDial;
        property int delIndex: -1
        message: "Точно удалить, без возможности воостановления?"
        titleText: "Удалить?"
        acceptButtonText: "OK";
        height: 200;
        rejectButtonText: "Отмена"
        onAccepted: {
            application.remove(delIndex);
        }
    }

    DriveInfoComponent{
        id: drive;
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 5;
        anchors.rightMargin: 5;
        anchors.top: parent.top;
        anchors.topMargin: 5;
    }

    Text {
            id: header
            visible: true;
            text: "Выберите, что удалять:"
            color:"white"
            //font.pixelSize: 16;
            horizontalAlignment: Text.AlignJustify
            wrapMode: Text.WordWrap;
            anchors.top: drive.bottom
            anchors.topMargin: 5;

        }

    ListView{
        id:flick
        visible:true;
        anchors.top: header.bottom;
        anchors.bottom: addButton.top
        anchors.bottomMargin: inputContext.visible?inputContext.height-50-addButton.height:5
        anchors.topMargin: 5;
        cacheBuffer: 600;
        anchors.left: parent.left;
        anchors.right: parent.right
        //contentWidth: parent.width;
        //contentHeight: c.height+20
        //flickableDirection: Flickable.VerticalFlick
        clip: true
                model: application.categoryModel
                delegate: Component{
                    Item{
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
                            height: root.editMode?apptxt2.height:apptxt1.height;
                            Text{
                                id: apptxt1
                                visible: !root.editMode;
                                anchors.left: parent.left
                                anchors.right: parent.right
                                color:"white"
                                wrapMode: Text.WordWrap;
                                text: modelData.localName
                                font.pixelSize: sw.height*0.5

                            }
                            TextField{
                                id: apptxt2
                                visible: root.editMode;
                                anchors.left: parent.left
                                anchors.right: parent.right
                                text: modelData.localName
                                onTextChanged: {modelData.localName=text;}
                                onActiveFocusChanged: t.start();
                                Timer{
                                    id: t;
                                    onTriggered: flick.positionViewAtIndex(index,ListView.Contain);
                                    interval: 100;
                                    repeat: false;
                                }
                            }

                        }
                        Item{
                            id:sw
                            property int click: 0
                            anchors.right: parent.right
                            anchors.rightMargin: 10;
                            anchors.verticalCenter: parent.verticalCenter
                            height: root.editMode?sw2.height:sw1.height;
                            width: root.editMode?sw2.width+sw1.width+sw3.width:sw1.width;
                            Switch{
                                Connections{
                                    target: root
                                    onEditModeChanged:{
                                        if(root.editMode) sw1.checked=modelData.initialChecked;
                                        else sw1.checked=modelData.checked;
                                    }
                                }

                                id: sw1
                               // visible: root.editMode;
                                anchors.right: parent.right
                                anchors.rightMargin: root.editMode?sw2.width*2+10:0
                                checked: modelData.checked
                                onClicked: {
                                    if (root.editMode) modelData.initialChecked=checked;
                                    else modelData.checked=checked;
                                }
                            }
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
                                onClicked: {application.selectCategory(index); root.pageStack.push(Qt.resolvedUrl("FilesPage.qml"),{"tools":filesTB,"itemIndex":index})}
                            }

                        }

                    }
                }
                Component.onCompleted: {
                    if (!application.checkRoot()){
                        rootDialog.open();
                    }
                }
            }
    ToolBarLayout {
        id: filesTB;
        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked:{application.saveFiles(); window.pageStack.pop();}
        }
    }
    Button{
        id: addButton;
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 10;
        anchors.rightMargin: 10;
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5;
        height: root.editMode?50:0;
        text: "Добавить категорию"
        onClicked: application.addNew();
    }
/*
    Connections{
        target: application
        onDeleteStarted: busy.visible=true;
        onDeleteFinished: busy.visible=false;
    }
*/

    Rectangle{
        id: results;
        visible: false
        color:"black";
        anchors.fill: parent;
        MouseArea{
            visible: parent.visible
            anchors.fill: parent
            onClicked: {}
        }
        Column{
            id:c1
            spacing: 10;
            anchors.top: parent.top//statusBar.bottom;
            //anchors.bottom: parent.bottom//toolBar.top;
            anchors.left: parent.left;
            anchors.right: parent.right
            anchors.topMargin: 20;
            anchors.verticalCenter: parent.verticalCenter
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                id: logo
                source: "done.svg"
                width: 200; height: 200;
                sourceSize.width: 200;
                sourceSize.height: 200;
                MouseArea{
                    anchors.fill: parent
                    onPressAndHold: edit();
                }
            }
            Text{
                text:"Удалено";
                color:"white"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter;
                anchors.left: parent.left;
                anchors.right: parent.right
                font.pixelSize: 35;
                wrapMode: Text.WordWrap
            }

            Text{
                text: "Удалено "+application.deletedCount+" файлов\n"+application.deletedSize;
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter;
                anchors.left: parent.left;
                anchors.right: parent.right
                font.pixelSize: 20;
                color:"white"
                wrapMode: Text.WordWrap

            }
        }
        Button{
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 10;
            anchors.rightMargin: 10;
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5;
            height: 50;
            text: "OK"
            onClicked: {results.visible=false;}
        }
    }
    Rectangle{
        id: busy;
        visible: application.deleteInProgress
        color:"black";
        onVisibleChanged: {
            if (visible)
            {
                results.visible=true;
            }
            drive.updateList();
        }

        anchors.fill: parent;
        BusyIndicator{
            width: 150
            height: 150;
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100;
            running: parent.visible
        }
        MouseArea{
            visible: parent.visible
            anchors.fill: parent
            onClicked: {}
        }

        Text {
            text: "Идет удаление...\nУдалено "+application.deletedCount+" файлов\n"+application.deletedSize;
            color:"white"
            horizontalAlignment: Text.AlignHCenter
            anchors.centerIn: parent;
            anchors.verticalCenterOffset: 70;
        }
    }
}
