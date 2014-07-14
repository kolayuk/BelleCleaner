#include "asynctask.h"
#include <QFileInfo>
#include <QDir>
#include <QDirIterator>
#ifdef Q_OS_SYMBIAN
#include <bautils.h>
#endif

AsyncTask::AsyncTask(QObject *parent) :
    QThread(parent)
{
    setTerminationEnabled(true);
}

AsyncTask::AsyncTask(QList<QObject *> *list, QObject *parent):QThread(parent)
{
    setTerminationEnabled(true);
    setList(list);
    mStopped=false;
}

void AsyncTask::setList(QList<QObject *> *list)
{
    mList=*list;
}

void AsyncTask::run()
{
    //qDebug()<<"run";

    //qDebug()<<"list"<<&mList;
    //qDebug()<<"accessing";
   // qDebug()<<mList.count();
    mCount=0;
    mTotalSize=0;
    setResetNeeded(false);
    foreach (QObject* obj,mList)
    {
        DeleteItem* it=qobject_cast<DeleteItem*>(obj);
        if (it->getChecked())
        {
            if (mStopped) break;
            foreach (QString file, it->getFileList()){
                if (file.isEmpty()) continue;
                if (mStopped) break;
                if (file.contains("KILL ")){
                    QString uid=file.replace("KILL ","");
                    killProccess(uid);
                    continue;
                }
                if (file.contains("RESET")){
                    setResetNeeded(true);
                    continue;
                }
                //qDebug()<<"applying "<<file;
                QFileInfo info(file);
                if (file.contains("*")||file.contains("?")){
                    if (info.dir().canonicalPath().isEmpty()) continue;
                    file=file.replace(info.dir().canonicalPath()+"/","");
                    QFileInfoList list=info.dir().entryInfoList(QStringList(file));
                    foreach(QFileInfo fileinfo,list) {
                       // qDebug()<<"file"<<fileinfo.canonicalPath();
                        if (fileinfo.isFile()){
                           // qDebug()<<"file"<<fileinfo.canonicalPath();
                            mTotalSize+=fileinfo.size();
                            mCount+=1;
                        }
                        else if (fileinfo.isDir())
                        {
                           // qDebug()<<"dir"<<fileinfo.baseName();
                            QDirIterator iterator(fileinfo.canonicalPath()+"/"+fileinfo.baseName(), QDirIterator::Subdirectories);
                               while (iterator.hasNext()) {
                                  iterator.next();
                                  if (!iterator.fileInfo().isDir()) {
                                     mTotalSize+=iterator.fileInfo().size();
                                     mCount+=1;
                                  }
                               }
                              // qDebug()<<"counted";
                               deleteDir(fileinfo.canonicalPath()+"/"+fileinfo.baseName()+"/"); // delete if item is a dir
                        }
                    }
                    qDebug()<<"file"<<file;
                    /*qDebug()<<"delete file"<<info.dir().canonicalPath()+"/"+file<<*/deleteFile(info.dir().canonicalPath()+"/"+file); // delete files in this dir
                    emit updateProgess(mCount,mTotalSize);
                }
                else if (info.exists()){

                    mCount+=1;
                    mTotalSize+=info.size();
#ifdef Q_OS_SYMBIAN
                    deleteFile(file);
#endif
                    emit updateProgess(mCount,mTotalSize);
                }
            }
        }
    }
    //qDebug()<<"finished";
    emit updateProgess(mCount,mTotalSize);
    emit finished();


}

void AsyncTask::stop()
{
    mStopped=true;
}

int AsyncTask::deleteFile(QString file)
{
    if (file=="/*"){qDebug()<<"/* ERROR!!!1111"; return -100500;}
    file=file.replace("/","\\");
    qDebug()<<"deleting file"<<file;
    if (file=="\\*") return -100500;
#ifdef Q_OS_SYMBIAN
    TPtrC aPath (static_cast<const TUint16*>(file.utf16()), file.length());
    TInt err;
    RFs session;
    session.Connect();
    CFileMan* manager = CFileMan::NewL(session);
    TRequestStatus status=KRequestPending;
    TTime now;
    now.HomeTime();
    int errAt=manager->Attribs(aPath,KEntryAttNormal,KEntryAttReadOnly|KEntryAttHidden|KEntryAttSystem,now,CFileMan::CFileMan::ERecurse);
    qDebug()<<"set attrib"<<errAt;
    err = manager->Delete(aPath,CFileMan::ERecurse);
    delete manager;
    session.Close();
   // qDebug()<<"deleted file"<<err;
    return err;
#elif defined(Q_OS_WIN)
    return 0;
#endif
}

int AsyncTask::deleteDir(QString file)
{
    file=file.replace("/","\\");
    qDebug()<<"deleting dir"<<file;
    if (file=="\\*") return-100500;
#ifdef Q_OS_SYMBIAN
    TPtrC aPath (static_cast<const TUint16*>(file.utf16()), file.length());
    TInt err;
    RFs session;
    session.Connect();
    CFileMan* manager = CFileMan::NewL(session);
    TTime now;
    now.HomeTime();
    int errAt=manager->Attribs(aPath,KEntryAttNormal,KEntryAttReadOnly|KEntryAttHidden|KEntryAttSystem,now,CFileMan::CFileMan::ERecurse);
    qDebug()<<"set attrib"<<errAt;
    err = manager->RmDir(aPath);
    //qDebug()<<"deleted directory"<<err;
    return err;
#elif defined(Q_OS_WIN)
    return 0;
#endif

}

int AsyncTask::killProccess(QString uid)
{

#ifdef Q_OS_SYMBIAN
    TPtrC aPath (static_cast<const TUint16*>(uid.utf16()), uid.length());
    TRAPD(err,
            {
          TBuf<255> a(_L("*"));
            a.Append(aPath);
            a.Append(_L("*"));
            TFindProcess processFinder(a); // by name, case-sensitive
            TFullName result;
            RProcess processHandle;
            while ( processFinder.Next(result) == KErrNone)
            {
               User::LeaveIfError(processHandle.Open ( processFinder, EOwnerThread));
               processHandle.Kill(KErrNone);
               processHandle.Close();
            }
            });
TRAPD(err2,
        {
      TBuf<255> a(_L("*"));
        a.Append(aPath);
        a.Append(_L("*"));
        TFindProcess processFinder(a); // by name, case-sensitive
        TFullName result;
        RProcess processHandle;
        while ( processFinder.Next(result) == KErrNone)
        {
           User::LeaveIfError(processHandle.Open ( processFinder, EOwnerThread));
           processHandle.Kill(KErrNone);
           processHandle.Close();
        }
        });
       // qDebug()<<"process"<<uid<<"killed"<<err<<err2;
}
#endif

/*

    */
