#include "wakebase.h"
#include <QProcess>
#include <QDebug>

WakeBase::WakeBase(QObject *parent) :
    QObject(parent)
{
    m_saver = new QSystemScreenSaver(this);
}

void WakeBase::setValue(int value)
{
    QProcess gconftool;
    QString num;
    num.setNum(value);
    QStringList args = QStringList() << "-s" << "/system/osso/dsm/display/display_brightness" << "-t" << "int" << num;
    qDebug() << "Resetting brightness: " << args;
    gconftool.start("gconftool-2", args);
    gconftool.waitForFinished();

}

int WakeBase::getValue()
{
    int result = 3;
    QProcess gconftool;
    gconftool.start("gconftool-2", QStringList() << "-g" << "/system/osso/dsm/display/display_brightness");
    if (gconftool.waitForFinished()) {
        QByteArray output = gconftool.readAll();
        result = output[0] - '0';
        qDebug() << "Current brightness [" << result << "]";
    }

    return result;

}

bool WakeBase::getScreenSaverStatus()
{
    return m_saver->screenSaverInhibited();
}

void WakeBase::setScreenSaverInhibit()
{
    m_saver->setScreenSaverInhibit();
}

void WakeBase::setScreenSaverInhibited(bool enable)
{
    m_saver->setScreenSaverInhibited(enable);
}
