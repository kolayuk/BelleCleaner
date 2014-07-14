#ifndef ASYNCTASK_H
#define ASYNCTASK_H

#include <QObject>
#include <deleteitem.h>
#include <QDebug>
#ifdef Q_OS_SYMBIAN
#include <e32base.h>
#include <f32file.h>
#endif
#include <QThread>

class AsyncTask : public QThread
{
    Q_OBJECT
    QList<QObject*> mList;
    bool mStopped;
    int mCount;
    int mTotalSize;
    int deleteFile(QString file);
    int deleteDir(QString dir);
    int killProccess(QString uid);
public:
    explicit AsyncTask(QObject *parent = 0);
    explicit AsyncTask(QList<QObject*>* list,QObject *parent = 0);
    void setList(QList<QObject*>* list);

signals:
    void finished(bool inProgress=false);
    void updateProgess (int count, int bytes);
    void setResetNeeded(bool value);
public slots:
    void run();
    void stop();
};

#endif // ASYNCTASK_H
