import QtQuick 1.1
import com.nokia.symbian 1.1
import App 1.0
Page {
    id: root
    Text {
            id: header
            visible: true;
            text: qsTr("Введите список файлов, каждый на новой строке:")
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
    TextArea {
        id:area
        visible:true;
        anchors.top: header.bottom;
        anchors.bottom: okbtn.top
        anchors.bottomMargin: 5
        anchors.topMargin: 5;
        anchors.left: parent.left;
        anchors.right: parent.right

    }
    Button{
        id: okbtn;
        anchors.left: parent.left
        anchors.leftMargin: 10;
        width: parent.width/2-20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5;
        height: 50;
        text: qsTr("Отмена")
        onClicked: root.pageStack.pop();
    }
    Button{
        id: addButton2;
        anchors.right: parent.right
        anchors.rightMargin: 10;
        width: parent.width/2-20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5;
        height: 50;
        text: qsTr("ОК")
        onClicked: {application.addALotFiles(area.text); root.pageStack.pop();}
    }


}
