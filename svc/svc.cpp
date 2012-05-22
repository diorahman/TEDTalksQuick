#include "svc.h"

#include <QDebug>
#include <QDateTime>

#ifdef HARMATTAN_BOOSTER
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#include <MDataUri>
#endif

StandardSvc::StandardSvc(QObject *parent) :
    QObject(parent)
{

}

void StandardSvc::share(QString title, QString url)
{
#ifdef HARMATTAN_BOOSTER
    MDataUri dataUri;
    dataUri.setMimeType("text/x-url");
    dataUri.setTextData(url);
    dataUri.setAttribute("title", title);
    dataUri.setAttribute("description", "");

    QStringList items;
    items << dataUri.toString();
    ShareUiInterface shareIf("com.nokia.ShareUi");
    if (shareIf.isValid()) {
        shareIf.share(items);
    } else {
        qCritical() << "Invalid interface";
    }
#endif
}

QString StandardSvc::toGMTPlus7(const QString &date)
{
    return QDateTime::fromString(date.mid(0, date.indexOf("GMT")).trimmed(), "ddd, dd MMM yyyy HH:mm:ss")
            .addSecs(60 * 60 * 7)
            .toString("ddd, dd MMM yyyy HH:mm") + " WIB";
}
