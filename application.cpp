#include "application.h"
#include <QFile>
#include <QDebug>
#include <QFileInfo>
#include <QDir>
#include <QThread>
#include <asynctask.h>
#include <math.h>

#include <starterclient.h>

Application::Application(QObject *parent) :
    QObject(parent)
{
    setDeleteInProgress(false);
    setDeletedSize(0);
    setDeletedCount(0);
    QString settingPath=QString("C:\\System\\Apps\\PureClean\\config"+QString::number(User::Language())+".ini");
    if (!QFile::exists(settingPath))
        settingPath=QString("C:\\System\\Apps\\PureClean\\config1.ini");
        data=new QSettings(settingPath,QSettings::IniFormat);
    QStringList files;
    QStringList keys;
    foreach (QString group, data->childGroups())
    {
        DeleteItem* it=new DeleteItem(this);
        data->beginGroup(group);
        it->setLocalName(data->value("localName","undefined").toString());
        it->setChecked(data->value("checked",0).toInt()==1);
        it->setInitialChecked(data->value("checked",0).toInt()==1);
        it->setCategoryName(group);
        files.clear();
        keys=data->allKeys();
        keys.removeOne("localName");
        keys.removeOne("checked");
        foreach(QString key, keys) files.append(data->value(key,"").toString());
        it->setFileList(files);
        connect(it,SIGNAL(localNameChanged(QString)),this,SLOT(itemChanged()));
        connect(it,SIGNAL(initialCheckedChanged(bool)),this,SLOT(itemChanged()));
        connect(it,SIGNAL(fileListChanged(QStringList)),this,SLOT(itemChanged()));
        connect(it, SIGNAL(fileListChanged(QStringList)),this,SIGNAL(filesModelChanged(QStringList)));
        itemsToDel.append(it);
        data->endGroup();
    }

}

QStringList Application::getFilesModel() const
{
    DeleteItem* it=qobject_cast<DeleteItem*>(itemsToDel.at(currentIndex));
    return it->getFileList();
}

bool Application::getDeleteInProgress() const
{
    return m_deleteInProgress;
}

QString Application::getDeletedSize() const
{
    return m_deletedSize;
}

int Application::getDeletedCount() const
{
    return m_deletedCount;
}

bool Application::checkRoot()
{
    const QString checkPath=QString("C:\\sys\\bin\\test.ini");
    QSettings* test=new QSettings(checkPath,QSettings::IniFormat);
    test->setValue("1","test");
    test->sync();
    QFile f(checkPath);
    bool ex=f.exists();
    if (ex) f.remove();
    qDebug()<<"root access"<<ex;
    if (ex) {return true;}
    else return false;

}

QList<QObject*> Application::getCategoryModel() const
{
    //qDebug()<<"getting model";
    return itemsToDel;
}
/*
QList<QObject *> Application::getCategoryModel1() const
{
    qDebug()<<"getting model 1";
    QList<QObject*> list; int i=0;
    foreach (DeleteItem* item, itemsToDel) {list.append(item);qDebug()<<i;i++;}
    return list;
}
*/
void Application::setCategoryModel(const QList<QObject*> &list)
{
    if (list!=itemsToDel)
    {
        itemsToDel=list;
        emit categoryModelChanged();
    }
}

void Application::itemChanged()
{
    DeleteItem* it=qobject_cast<DeleteItem*>(sender());
    data->remove(it->getCategoryName());
    //qDebug()<<"edit"<<it->getLocalName();
    data->setValue(it->getCategoryName()+"/localName",it->getLocalName());
    data->setValue(it->getCategoryName()+"/checked",it->getInitialChecked()?1:0);
    QStringList l=it->getFileList();
    for (int i=0;i<l.count();i++)
    {
        data->setValue(it->getCategoryName()+"/"+QString::number(i),l.at(i));
    }
    data->sync();
    data->sync();
}

void Application::remove(int index)
{
    DeleteItem* it=qobject_cast<DeleteItem*>(itemsToDel.at(index));
    data->remove(it->getCategoryName());
    itemsToDel.removeAt(index);
    emit categoryModelChanged();
}

void Application::addNew()
{
    DeleteItem* it=new DeleteItem();
    int i;
    for (i=0;i<itemsToDel.count()+1;i++)
        if (!data->childGroups().contains("cat"+QString::number(i))) break;
    it->setCategoryName("cat"+QString::number(i));
    it->setInitialChecked(true);
    it->setLocalName("undefined");
    it->setChecked(true);
    QStringList l;
    it->setFileList(l);
    connect(it,SIGNAL(localNameChanged(QString)),this,SLOT(itemChanged()));
    connect(it,SIGNAL(initialCheckedChanged(bool)),this,SLOT(itemChanged()));
    connect(it,SIGNAL(fileListChanged(QStringList)),this,SLOT(itemChanged()));
    connect(it, SIGNAL(fileListChanged(QStringList)),this,SIGNAL(filesModelChanged(QStringList)));
    itemsToDel.append(it);
    data->setValue(it->getCategoryName()+"/localName",it->getLocalName());
    data->setValue(it->getCategoryName()+"/checked",it->getInitialChecked()?1:0);
    data->sync();
    emit categoryModelChanged();
}

void Application::removeFile(int fileIndex, int itemIndex)
{
    DeleteItem* it=qobject_cast<DeleteItem*>(itemsToDel.at(itemIndex));
    it->removeFile(fileIndex);

}

void Application::setFilesModel(const QStringList &filesModel)
{
    DeleteItem* it=qobject_cast<DeleteItem*>(itemsToDel.at(currentIndex));
    it->setFileList(filesModel);
    emit filesModelChanged(filesModel);
}

void Application::addFile(int itemIndex, QString path)
{
    DeleteItem* it=qobject_cast<DeleteItem*>(itemsToDel.at(itemIndex));
    it->addFile(path);
}

void Application::setFile(int fileIndex, int itemIndex, QString path)
{
    //qDebug()<<"savefile"<<fileIndex<<itemIndex;
    DeleteItem* it=qobject_cast<DeleteItem*>(itemsToDel.at(itemIndex));
    it->setFile(fileIndex,path);
    //emit filesModelChanged();
}

void Application::selectCategory(int index)
{
    currentIndex=index;
}

void Application::saveFiles()
{
    //qDebug()<<"write to file";
    DeleteItem* it=qobject_cast<DeleteItem*>(itemsToDel.at(currentIndex));
    QStringList l=it->getFileList();
    for (int i=0;i<l.count();i++)
    {
        data->setValue(it->getCategoryName()+"/"+QString::number(i),l.at(i));
    }
    data->sync();
}

void Application::deleteSelected()
{

    emit deleteStarted();
    /*
    QThread* thread=new QThread();
    AsyncTask* task=new AsyncTask(&itemsToDel,this);
    QObject::connect(thread,SIGNAL(started()),task,SLOT(run()),Qt::QueuedConnection);
    QObject::connect(task,SIGNAL(finished()),thread,SLOT(terminate()),Qt::QueuedConnection);
    //QObject::connect(thread,SIGNAL(terminated()),this,SIGNAL(deleteFinished()),Qt::QueuedConnection);
    QObject::connect(task,SIGNAL(finished()),this,SIGNAL(deleteFinished()),Qt::QueuedConnection);
    task->moveToThread(thread);
    thread->start();
    */
    mResetNeeded=false;
    setDeleteInProgress(true);
    task=new AsyncTask(&itemsToDel,this);
    QObject::connect(task,SIGNAL(finished(bool)),this,SLOT(setDeleteInProgress(bool)),Qt::QueuedConnection);
    QObject::connect(task,SIGNAL(setResetNeeded(bool)),this,SLOT(setResetNeeded(bool)),Qt::QueuedConnection);
    QObject::connect(task,SIGNAL(terminated()),task,SLOT(deleteLater()));
    QObject::connect(task,SIGNAL(finished()),task,SLOT(deleteLater()));
    QObject::connect(task,SIGNAL(updateProgess(int,int)),this,SLOT(updateProgress(int,int)));
    task->start();

}

void Application::addALotFiles(QString text)
{
    //qDebug()<<"adding text";
    text=text.replace("\r","");
    QStringList newvals=text.split("\n");
    //qDebug()<<newvals;
    DeleteItem* it=qobject_cast<DeleteItem*>(itemsToDel.at(currentIndex));
    it->addFiles(newvals);
    emit filesModelChanged(it->getFileList());
}

void Application::setDeleteInProgress(bool arg)
{
    if (m_deleteInProgress != arg) {
        m_deleteInProgress = arg;
        emit deleteInProgressChanged(arg);
    }
}

void Application::stopDelete()
{
    //qDebug()<<"terminating";
    if (m_deleteInProgress){
        task->stop();
        setDeleteInProgress(false);
    }

}

void Application::updateProgress(int count, int totalSize)
{
    m_deletedCount=count;
    double size=0;
    //qDebug()<<"total"<<totalSize;
    QString suffix="";
    if (totalSize>pow(2.0,30)) {size=round((double)totalSize/pow(2.0,30)*100)/100.0; suffix="Gb";}
    else if (totalSize>pow(2.0,20)) {size=round((double)totalSize/pow(2.0,20)*100)/100.0; suffix="Mb";}
    else if (totalSize>pow(2.0,10)) {size=round(((double)totalSize/pow(2.0,10))*100)/100.0; suffix="Kb";}
    else {size=totalSize; suffix="b";}
    m_deletedSize=QString::number(size)+suffix;
    //qDebug()<<"converted"<<m_deletedSize;
    emit deletedCountChanged(count);
    emit deletedSizeChanged(m_deletedSize);
}

void Application::setDeletedSize(QString arg)
{
    if (m_deletedSize != arg) {
        m_deletedSize = arg;
        emit deletedSizeChanged(arg);
    }
}

void Application::setDeletedCount(int arg)
{
    if (m_deletedCount != arg) {
        m_deletedCount = arg;
        emit deletedCountChanged(arg);
    }
}

void Application::updateFiles()
{
    DeleteItem* it=qobject_cast<DeleteItem*>(itemsToDel.at(currentIndex));
    emit it->fileListChanged(it->getFileList());
}

void Application::reset()
{
    if (mResetNeeded)
    {
        RStarterSession starter;
        TInt err=starter.Connect();
        starter.Reset(starter.ELanguageSwitchReset);
        starter.Close();
    }
}

bool Application::isResetNeeded()
{
    return mResetNeeded;
}

void Application::setResetNeeded(const bool &val)
{
    mResetNeeded=val;
}

void Application::setAllCategoriesState(bool checked)
{
    foreach (QObject* obj, itemsToDel)
    {
        obj->setProperty("checked",checked);
    }
}





