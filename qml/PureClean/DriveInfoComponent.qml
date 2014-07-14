import Qt 4.7
import QtMobility.systeminfo 1.1
import "content"


Rectangle {
    width: 640
    height: 25*(lv.count-2);
    id: screen
    color: "transparent"

    StorageInfo {
        id: storageinfo
        onLogicalDrivesChanged: updateList();

    }

    function getTotalSizeText(name) {
        var totalSpace = storageinfo.totalDiskSpace(name);
        if(totalSpace/1024 < 1024) {
            return Math.round(totalSpace/1024)+" kb";
        } else if(totalSpace/1024/1024 < 1024) {
            return Math.round(totalSpace/1024/1024)+" Mb";
        } else if(totalSpace/1024/1024/1024 < 1024) {
            return Math.round(totalSpace/1024/1024/1024)+" Gb";
        }
        return "";
    }

    function getAvailableSizeText(name) {
        var dspace = storageinfo.totalDiskSpace(name)-storageinfo.availableDiskSpace(name);
        if(dspace/1024 < 1024) {
            return (dspace/1024).toFixed(2)+" kb/";
        } else if(dspace/1024/1024 < 1024) {
            return (dspace/1024/1024).toFixed(2)+" Mb/";
        } else if(dspace/1024/1024/1024 < 1024) {
            return (dspace/1024/1024/1024).toFixed(2)+" Gb/";
        }
        return "";
    }

    function getPercent(name) {
        return Math.round( 100 - ((storageinfo.availableDiskSpace(name) / storageinfo.totalDiskSpace(name)) * 100))
    }

    property variant driveList: [];//storageinfo.logicalDrives;

    function updateList() {
        driveList=storageinfo.logicalDrives;
    }

    ListView {
        id: lv;
        width: 100
        height: 100
        clip:true;
        anchors.fill: parent
        model: driveList
        delegate: Component {
            Item {
                width: 360; height: modelData=="D"||modelData=="Z"?0:25; x: 5;
                clip:true;
                Row {
                    width: parent.width
                    Text { id: name; text: modelData; width: 20; color: "white";}
                    Text { text: getAvailableSizeText(name.text); color: "white";}
                    Text { text: getTotalSizeText(name.text); color: "white"; }

                    property int maxval: 0
                    ProgressBar {
                        width: 120
                        height: 20

                        anchors.right: parent.right
                        anchors.rightMargin: 15;
                        maxval: getPercent(name.text)
                        value: getPercent(name.text)
                        NumberAnimation on value { duration: 1500; from: 0; to: getPercent(name.text); /*loops: Animation.Infinite*/ }
                        ColorAnimation on color { duration: 1500; from: "lightsteelblue"; to: "thistle"; /*loops: Animation.Infinite */}
                        ColorAnimation on secondColor { duration: 1500; from: "steelblue"; to: "#CD96CD"; loops: Animation.Infinite }
                    }
                }
            }
        }
    }
}
