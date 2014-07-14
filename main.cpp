#include <qglobal.h>
#if (QT_VERSION >= QT_VERSION_CHECK(5,0,0))
    #include <QApplication>
#else
    #include <QtGui/QApplication>
#endif
#include "qmlapplicationviewer.h"
#include "application.h"
#include "deleteitem.h"
#include <QDeclarativeContext>
#include <QtDeclarative>
#include <filemodel.h>
#ifdef Q_OS_SYMBIAN
#include <e32debug.h>
#endif

#include <QTranslator>

Q_DECLARE_METATYPE(DeleteItem*)
Q_DECLARE_METATYPE(QList<DeleteItem*>)


void myMessageHandler(QtMsgType type, const char *msg)
{
        QString txt;
        QTime t=QTime::currentTime();
        QString st=t.toString("hh:mm:ss");
        switch (type) {
        case QtDebugMsg:
                txt = QString(" %1").arg(msg);
                break;
        case QtWarningMsg:
                txt = QString(" Warning: %1").arg(msg);
        break;
        case QtCriticalMsg:
                txt = QString(" Critical: %1").arg(msg);
        break;
        case QtFatalMsg:
                txt = QString(" Fatal: %1").arg(msg);
                abort();
        }
        txt=st+txt;
        QFile outFile("D:\\pureclean.txt");
        outFile.open(QIODevice::WriteOnly | QIODevice::Append);
        QTextStream ts(&outFile);
        ts << txt << endl;
#ifdef Q_OS_SYMBIAN
        TPtrC des (reinterpret_cast<const TText*>(txt.constData()),txt.length());
        RDebug::Print(des);
#endif
}


Q_DECL_IMPORT void qt_s60_setPartialScreenAutomaticTranslation(bool enable);
Q_DECL_IMPORT void qt_s60_setPartialScreenInputMode(bool enable);
Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QFile file("D:\\pureclean.txt");
    if (file.exists()){file.remove();}
    //qInstallMsgHandler(myMessageHandler);
    //QCoreApplication::setAttribute(Qt::AA_S60DisablePartialScreenInputMode, true);

    QTranslator myTranslator;
      myTranslator.load("bellecleaner_" + QLocale::system().name());
      app.data()->installTranslator(&myTranslator);

    //qt_s60_setPartialScreenAutomaticTranslation(false);
    //qt_s60_setPartialScreenInputMode(true);
    QmlApplicationViewer viewer;
    qmlRegisterType<DeleteItem>("App", 1,0,"DeleteItem");
    Application* a=new Application();
    FileModel fileModel;
    viewer.rootContext()->setContextProperty("fileModel", &fileModel);
    viewer.rootContext()->setContextProperty("application",a);
    //viewer.rootContext()->setContextProperty("mymodel",QVariant::fromValue(a->getCategoryModel()));
    viewer.setMainQmlFile(QLatin1String("qml/PureClean/main.qml"));
    viewer.showExpanded();

    return app->exec();
}
