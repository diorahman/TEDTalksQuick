#ifndef DOWNLOADMANAGER_H
#define DOWNLOADMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>

struct FileInfo {
    QUrl url;
    QString name;
    QString path;
    int status;
};

class DownloadManager : public QObject
{
    Q_OBJECT
public:
    explicit DownloadManager(QObject *parent = 0);

signals:
    void downloadComplete(const QString & name);

    void progress( int percentage);

    void error(const QString & error);

public slots:

    void download();

    void pause();

    void resume();

    bool exists(const QString & videoName);

    void setFileInfo(const QString & url);

    void deleteVideo(const QString & videoName);

    void fakeComplete();

    QString getFullPath(const QString & baseName);

private slots:

    void download( const QNetworkRequest& request);

    void finished();

    void downloadProgress ( qint64 bytesReceived, qint64 bytesTotal );

    void error ( QNetworkReply::NetworkError code );

private:

    QNetworkAccessManager* mManager;
    QNetworkRequest mCurrentRequest;
    QNetworkReply* mCurrentReply;
    QFile* mFile;
    FileInfo mFileInfo;
    int mDownloadSizeAtPause;

    bool mbusy;
};

#endif // DOWNLOADMANAGER_H
