#include <QtGui/QApplication>
#include <qdeclarative.h>
#include "qmlapplicationviewer.h"
#include "downloadmanager.h"
#include "svc.h"

#include "notifhelper.h"
#include "wakebase.h"
//#include "page.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    qmlRegisterType<DownloadManager>("labs.aegis.tedquick", 1, 0, "DownloadManager");
    qmlRegisterType<StandardSvc>("labs.aegis.apps", 1, 0, "StandardSvc");
    qmlRegisterType<NotifHelper>("labs.aegis.apps", 1, 0, "NotifHelper");
    qmlRegisterType<WakeBase>("labs.aegis.apps", 1, 0, "Wake");
    // qmlRegisterType<Page>("labs.aegis.apps", 1, 0, "Page");

    QmlApplicationViewer viewer;
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer.setMainQmlFile(QLatin1String("qml/tedquick/main.qml"));
    viewer.showExpanded();

    return app->exec();
}
