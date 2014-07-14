import QtQuick 1.1
import com.nokia.symbian 1.1

PageStackWindow {
    id: window
    initialPage: MainPage {
        id: mp;
        tools:toolBarLayout;
    }
    showStatusBar: true
    showToolBar: true
    QueryDialog{
        id: delDial;
        property int delIndex: -1
        message: qsTr("Очистить выбранные категории?")
        titleText: qsTr("Удалить?")
        acceptButtonText: qsTr("OK");
        height: 200;
        rejectButtonText: qsTr("Отмена")
        onAccepted: {
            application.deleteSelected();
        }
    }
    AboutPage{
        id: about;
        onEdit:{window.pageStack.pop();mp.editMode=!mp.editMode;}
        tools: backTB;

    }
    ToolBarLayout {
        id: backTB;
        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: window.pageStack.depth <= 1 ? Qt.quit() : window.pageStack.pop()
        }
    }

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: window.pageStack.depth <= 1 ? Qt.quit() : window.pageStack.pop()
        }
        ToolButton {
            flat: true
            text: application.deleteInProgress?qsTr("Стоп"):mp.editMode?"":qsTr("Очистить")
            onClicked: {
                if (application.deleteInProgress) application.stopDelete();
                else delDial.open();
            }
        }
        ToolButton {
            flat: true
            iconSource: "toolbar-menu"
            onClicked: window.pageStack.push(about);
        }
    }
}
