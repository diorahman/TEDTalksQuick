#ifndef NOTIFHELPER_H
#define NOTIFHELPER_H

#include <QObject>
#include <QVariant>

class QSettings;
class OviNotificationSession;
class NotificationModel;


class NotifHelper : public QObject
{
    Q_OBJECT

public:
    explicit NotifHelper(QObject *parent = 0);
    ~NotifHelper();

public slots:
    void activate();
    void registerApplication(QVariant id);
    void unregisterApplication();
    void cancel();
    void nid();

private:
    void initialize();

private slots:
    void changedState(QObject*);
    void notificationReceived(QObject*);

signals:
    void alarmReceived();
    void notificationModelChanged();
    void busy(bool isBusy);
    void notificationError();
    void notify(QString message);

private:
    OviNotificationSession *m_notificationSession; // Owned
    bool m_cancelled;
};

#endif // NOTIFHELPER_H
