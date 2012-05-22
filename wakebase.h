#ifndef WAKEBASE_H
#define WAKEBASE_H

#include <QObject>
#include <QSystemScreenSaver>

QTM_USE_NAMESPACE


class WakeBase : public QObject
{
    Q_OBJECT
public:
    explicit WakeBase(QObject *parent = 0);

signals:


public slots:
    void setValue(int value);
    int getValue();
    bool getScreenSaverStatus();
    void setScreenSaverInhibit();
    void setScreenSaverInhibited(bool enable);

private:
    QSystemScreenSaver * m_saver;

};

#endif // WAKEBASE_H
