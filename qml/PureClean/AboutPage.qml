// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Page{
    signal edit;
    Flickable {
        id: flickArea
        anchors.fill: parent

        contentWidth: parent.width; contentHeight: c.height
        flickableDirection: Flickable.VerticalFlick
        clip: true
        Column{
            id:c
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
                source: "logo.svg"
                width: 200; height: 200;
                sourceSize.width: 200;
                sourceSize.height: 200;
                MouseArea{
                    anchors.fill: parent
                    onPressAndHold: edit();
                }
            }
            Text{
                text:"BelleCleaner 1.0";
                color:"white"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter;
                anchors.left: parent.left;
                anchors.right: parent.right
                font.pixelSize: 35;
                wrapMode: Text.WordWrap
            }

            Text{
                text:qsTr("Разработчик: Николай<br>
Усанов-Корнилов<br>
Web: <a href=http://kolaysoft.ru>http://kolaysoft.ru/</a><br>
Twitter: <a href=http://twitter.com/kolayuk>@kolayuk</a><br>
VK: <a href=http://vk.com/kolayuk>http://vk.com/kolayuk</a><br>
<br>
Специально для Symbian Zone<br>
<a href=http://vk.com/symbian_zone>http://vk.com/symbian_zone</a>");
                color:"white"
                onLinkActivated: Qt.openUrlExternally(link);
                textFormat: Text.RichText
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter;
                anchors.left: parent.left;
                anchors.right: parent.right
                font.pixelSize: 20;
                wrapMode: Text.WordWrap

            }
        }
    }
}



