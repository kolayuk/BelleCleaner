#include "deleteitem.h"
#include <QDebug>
DeleteItem::DeleteItem(QObject *parent) :
    QObject(parent)
{
}

bool DeleteItem::getChecked() const
{
    return m_checked;
}

QString DeleteItem::getLocalName() const
{
    return m_localName;
}

QStringList DeleteItem::getFileList() const
{
    return m_fileList;
}

QString DeleteItem::getCategoryName() const
{
    return m_categoryName;
}

bool DeleteItem::getInitialChecked() const
{
    return m_initialChecked;
}

void DeleteItem::setChecked(bool arg)
{
    if (m_checked != arg) {
        m_checked = arg;
        qDebug()<<"setChecked"<<getLocalName()<<m_checked;
        emit checkedChanged(arg);
    }
}

void DeleteItem::setLocalName(QString arg)
{
    if (m_localName != arg) {
        m_localName = arg;
        emit localNameChanged(arg);
    }
}

void DeleteItem::setFileList(QStringList arg)
{
    if (m_fileList != arg) {
        m_fileList = arg;
        emit fileListChanged(arg);
    }
}

void DeleteItem::setCategoryName(QString arg)
{
    m_categoryName = arg;
}

void DeleteItem::setInitialChecked(bool arg)
{
    if (m_initialChecked != arg) {
        m_initialChecked = arg;
        emit initialCheckedChanged(arg);
    }
}

void DeleteItem::removeFile(int index)
{
    m_fileList.removeAt(index);

    emit fileListChanged(m_fileList);
}

void DeleteItem::addFile(QString path)
{
    m_fileList.append(path);
    emit fileListChanged(m_fileList);
}

void DeleteItem::setFile(int index, QString path)
{
    m_fileList.removeAt(index);
    m_fileList.insert(index, path);
    //emit fileListChanged(m_fileList);
}

void DeleteItem::addFiles(QStringList list)
{
    m_fileList.append(list);
    emit fileListChanged(m_fileList);
}
