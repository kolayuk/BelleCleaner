#ifndef APPLICATION_H
#define APPLICATION_H


#include <QObject>
#include <QSettings>
#include <DeleteItem.h>
#include <asynctask.h>


class Application : public QObject
{
    Q_OBJECT
    QSettings* data;
    QList<QObject*> itemsToDel;
    bool checked;
    int currentIndex;
    AsyncTask* task;
    bool m_deleteInProgress;

    QString m_deletedSize;
    bool mResetNeeded;
    int m_deletedCount;

    QList<QObject*> m_driveInfoModel;

public:
    Q_PROPERTY(QList<QObject*> categoryModel READ getCategoryModel WRITE setCategoryModel NOTIFY categoryModelChanged)
    Q_PROPERTY(QStringList filesModel READ getFilesModel WRITE setFilesModel NOTIFY filesModelChanged)
    Q_PROPERTY(bool deleteInProgress READ getDeleteInProgress WRITE setDeleteInProgress NOTIFY deleteInProgressChanged)
    Q_PROPERTY(QString deletedSize READ getDeletedSize WRITE setDeletedSize NOTIFY deletedSizeChanged)
    Q_PROPERTY(int deletedCount READ getDeletedCount WRITE setDeletedCount NOTIFY deletedCountChanged)
    explicit Application(QObject *parent = 0);

QStringList getFilesModel() const;

bool getDeleteInProgress() const;

QString getDeletedSize() const;

int getDeletedCount() const;

signals:
void categoryModelChanged();
void filesModelChanged(QStringList arg);
void deleteStarted();
void deleteFinished();

void deleteInProgressChanged(bool arg);

void deletedSizeChanged(QString arg);

void deletedCountChanged(int arg);

public slots:
    bool checkRoot();
    QList<QObject*> getCategoryModel() const;
    void setCategoryModel(const QList<QObject*>& list);
    void itemChanged();
    void remove(int index);
    void addNew();
    void removeFile(int fileIndex, int itemIndex);
    void setFilesModel(const QStringList& filesModel);
    void addFile(int itemIndex, QString path);
    void setFile(int fileIndex, int itemIndex,QString path);
    void selectCategory(int index);
    void saveFiles();
    void deleteSelected();
    void addALotFiles(QString text);
    void setDeleteInProgress(bool arg);
    void stopDelete();
    void updateProgress(int count, int totalSize);
    void setDeletedSize(QString arg);
    void setDeletedCount(int arg);
    void updateFiles();
    void reset();
    bool isResetNeeded();
    void setResetNeeded(const bool& val);
    void setAllCategoriesState(bool checked);
};

#endif // APPLICATION_H
