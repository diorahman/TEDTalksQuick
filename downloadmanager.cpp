#include "downloadmanager.h"

#include <QDebug>
#include <QDesktopServices>
#include <QStringList>

DownloadManager::DownloadManager(QObject *parent) :
    QObject(parent),mCurrentReply(0),mFile(0),mDownloadSizeAtPause(0)
{
    mManager = new QNetworkAccessManager( this );
}

void DownloadManager::download()
{
    if(!mbusy && mFileInfo.status == 0){
        mbusy = true;
        mFileInfo.status = 1;
        mDownloadSizeAtPause = 0;

        mCurrentRequest = QNetworkRequest(mFileInfo.url);
        download(mCurrentRequest);
    }

}

void DownloadManager::pause()
{
    qDebug() << "pause()";

    if(!mCurrentReply) {
        return;
    }

    disconnect(mCurrentReply,SIGNAL(finished()),this,SLOT(finished()));
    disconnect(mCurrentReply,SIGNAL(downloadProgress(qint64,qint64)),this,SLOT(downloadProgress(qint64,qint64)));
    disconnect(mCurrentReply,SIGNAL(error(QNetworkReply::NetworkError)),this,SLOT(error(QNetworkReply::NetworkError)));

    mCurrentReply->abort();

    mFile->write( mCurrentReply->readAll());
    mFile->deleteLater();
    mCurrentReply->deleteLater();
}

void DownloadManager::resume()
{
    mCurrentRequest = QNetworkRequest(mFileInfo.url);
    download(mCurrentRequest);
}

bool DownloadManager::exists(const QString &videoName)
{
    if(videoName.length())
        return QFile::exists(QDesktopServices::storageLocation(QDesktopServices::MoviesLocation) + "/tedvideo/" + videoName);
    else
        return false;
}

void DownloadManager::setFileInfo(const QString &url)
{
    QStringList list = QUrl(url).path().split("/");

    mFileInfo.url = QUrl(url);
    mFileInfo.name = list.last();
    mFileInfo.path = QDesktopServices::storageLocation(QDesktopServices::MoviesLocation) + "/tedvideo/" + list.last();
    mFileInfo.status = 0;
}

void DownloadManager::deleteVideo(const QString &videoName)
{
    if(exists(videoName)){
        QFile::remove(QDesktopServices::storageLocation(QDesktopServices::MoviesLocation) + "/tedvideo/" + videoName);
    }

    if(exists(videoName + ".part")){
        QFile::remove(QDesktopServices::storageLocation(QDesktopServices::MoviesLocation) + "/tedvideo/" + videoName + ".part");
    }
}

void DownloadManager::fakeComplete()
{
    emit downloadComplete(mFileInfo.name);
}

QString DownloadManager::getFullPath(const QString &videoName)
{
    return QDesktopServices::storageLocation(QDesktopServices::MoviesLocation) + "/tedvideo/" + videoName;
}

void DownloadManager::download( const QNetworkRequest& request)
{
    mFile = new QFile(mFileInfo.path + ".part", this);
    mFile->open(QIODevice::ReadWrite);
    mFile->seek(mFile->size());

    mDownloadSizeAtPause = mFile->size();
    QByteArray rangeHeaderValue = "bytes=" + QByteArray::number(mDownloadSizeAtPause) + "-";
    mCurrentRequest.setRawHeader("Range",rangeHeaderValue);

    mCurrentReply = mManager->get(request);

    connect(mCurrentReply,SIGNAL(finished()),this,SLOT(finished()));
    connect(mCurrentReply,SIGNAL(downloadProgress(qint64,qint64)),this,SLOT(downloadProgress(qint64,qint64)));
    connect(mCurrentReply,SIGNAL(error(QNetworkReply::NetworkError)),this,SLOT(error(QNetworkReply::NetworkError)));
}

void DownloadManager::finished()
{
    mbusy = false;
    mFileInfo.status = 2;

    mFile->close();
    mFile->rename(mFileInfo.path + ".part", mFileInfo.path);

    mFile->deleteLater();
    mCurrentReply->deleteLater();

    emit downloadComplete(mFileInfo.name);
}

void DownloadManager::downloadProgress ( qint64 bytesReceived, qint64 bytesTotal )
{
    mFile->write( mCurrentReply->readAll() );
    int percentage = ((mDownloadSizeAtPause+bytesReceived) * 100.0 )/ (mDownloadSizeAtPause+bytesTotal);
    emit progress(percentage);
}

void DownloadManager::error(QNetworkReply::NetworkError code)
{
    Q_UNUSED(code)
    emit error("Download error");
}
