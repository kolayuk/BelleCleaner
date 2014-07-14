import QtQuick 1.1
import com.nokia.symbian 1.1
import App 1.0
//import QtMobility.systeminfo 1.2

Page {
    id: root
    property bool editMode: false
    OkDialog{
        id:rootDialog;
        helpText: qsTr("Пожалуйста, включите патч Open4All для полноценной работы PureCleaner")
    }
    QueryDialog{
        id: delDial;
        property int delIndex: -1
        message: qsTr("Точно удалить, без возможности воостановления?")
        titleText: qsTr("Удалить?")
        acceptButtonText: qsTr("OK");
        height: 200;
        rejectButtonText: qsTr("Отмена")
        onAccepted: {
            application.remove(delIndex);
        }
    }

    QueryDialog{
        id: resetdial;
        message: qsTr("После очистки рекомендуется перезагрузка. Перезагрузить устройство?")
        titleText: qsTr("Перезагрузить?")
        acceptButtonText: qsTr("OK");
        height: 200;
        rejectButtonText: qsTr("Отмена")
        onAccepted: {
            application.reset();
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
        anchors.left: parent.left
        anchors.right: swall.left
        anchors.top: drive.bottom
        anchors.topMargin: 5
        anchors.leftMargin: 10
        color:"white"
        wrapMode: Text.WordWrap;
        text: qsTr("Выберите категории для удаления:")
        font.pixelSize: sw.height*0.5
        anchors.verticalCenter: icon.verticalCenter

    }
    Switch{
        id:sw
        anchors.right: parent.right
        anchors.rightMargin: 10;
        anchors.verticalCenter: header.verticalCenter
        checked: false
        onClicked: {application.setAllCategoriesState(checked);}

    }

    ListView{
        id:flick
        visible:true;
        anchors.top: header.bottom;
        anchors.bottom: addButton.top
        anchors.bottomMargin: 5
        anchors.topMargin: 15;
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
                                Connections{
                                    target: modelData;
                                    onCheckedChanged: sw1.checked=modelData.checked;
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
        text: qsTr("Добавить категорию")
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
                text:qsTr("Удалено");
                color:"white"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter;
                anchors.left: parent.left;
                anchors.right: parent.right
                font.pixelSize: 35;
                wrapMode: Text.WordWrap
            }

            Text{
                text: qsTr("Удалено ")+application.deletedCount+qsTr(" файлов\n")+application.deletedSize;
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
            onClicked: {
                results.visible=false;
                if (application.isResetNeeded()){
                    resetdial.open();
                }
            }
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
            text: qsTr("Идет удаление...\nУдалено ")+application.deletedCount+qsTr(" файлов\n")+application.deletedSize;
            color:"white"
            horizontalAlignment: Text.AlignHCenter
            anchors.centerIn: parent;
            anchors.verticalCenterOffset: 70;
        }
    }
}
