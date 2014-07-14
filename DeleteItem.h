#ifndef DELETEITEM_H
#define DELETEITEM_H

#include <QObject>
#include <QStringList>
class DeleteItem: public QObject
{
    Q_OBJECT

    bool m_checked;
    QString m_localName;

    QStringList m_fileList;

    QString m_categoryName;

    bool m_initialChecked;

public:
    explicit DeleteItem(QObject *parent = 0);
    Q_PROPERTY(bool checked READ getChecked WRITE setChecked NOTIFY checkedChanged)
    Q_PROPERTY(QString localName READ getLocalName WRITE setLocalName NOTIFY localNameChanged)
    Q_PROPERTY(QStringList fileList READ getFileList WRITE setFileList NOTIFY fileListChanged)
    Q_PROPERTY(QString categoryName READ getCategoryName WRITE setCategoryName)
    Q_PROPERTY(bool initialChecked READ getInitialChecked WRITE setInitialChecked NOTIFY initialCheckedChanged)
    bool getChecked() const;
    QString getLocalName() const;
    QStringList getFileList() const;
    QString getCategoryName() const;

    bool getInitialChecked() const;

signals:
    void checkedChanged(bool arg);
    void localNameChanged(QString arg);

    void fileListChanged(QStringList arg);

    void initialCheckedChanged(bool arg);

public slots:
    void setChecked(bool arg);
    void setLocalName(QString arg);
    void setFileList(QStringList arg);
    void setCategoryName(QString arg);
    void setInitialChecked(bool arg);
    void removeFile(int index);
    void addFile(QString path);
    void setFile(int index, QString path);
    void addFiles(QStringList list);
};

#endif // DELETEITEM_H
