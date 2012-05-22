/**
 * Copyright (c) 2012 Nokia Corporation.
 */

#include "notifhelper.h"

#include <QDate>
#include <QDebug>
#include <QPluginLoader>
#include <QSettings>
#include <QTime>
#include <QTimer>

// Notifications API headers
#include <ovinotificationinterface.h>
#include <ovinotificationsession.h>
#include <ovinotificationinfo.h>
#include <ovinotificationmessage.h>
#include <ovinotificationstate.h>
#include <ovinotificationpayload.h>


/*!
  \class NotifHelper
  \brief Helper class for usage of Nokia Notifications API
*/


/*!
  Constructor
*/
NotifHelper::NotifHelper(QObject *parent) :
    QObject(parent),
    m_notificationSession(0)
{
}


/*!
  Destructor
*/
NotifHelper::~NotifHelper()
{
    delete m_notificationSession;
}

/*!
  Activates Notifications API
*/
void NotifHelper::activate()
{
    qDebug() << "NotifHelper::activate()";

    if (!m_notificationSession)
        initialize();
}


/*!
  Registers Notifications API
  Application goes to online and can invoke API
*/
void NotifHelper::registerApplication(QVariant id)
{
    qDebug() << "NotifHelper::registerApplication()";

    m_cancelled = false;

    if (m_notificationSession) {
        m_notificationSession->registerApplication(id.toString());
        emit busy(true);
    }
}


/*!
  Unregisters Notifications API
  Application goes to offline
*/
void NotifHelper::unregisterApplication()
{
    qDebug() << "NotifHelper::unregisterApplication()";

    if (m_notificationSession) {
        m_notificationSession->unregisterApplication();
        emit busy(true);
    }
}


/*!
  User cancels registration to Notifications API
*/
void NotifHelper::cancel()
{
    qDebug() << "NotifHelper::cancel()";
    m_cancelled = true;
    emit busy(false);

    if (m_notificationSession) {
        m_notificationSession->unregisterApplication();
    }
}

void NotifHelper::nid()
{
    qDebug() << "NotifHelper::nid()";
    m_notificationSession->getNotificationInformation("service.aegis.co.id");
}


/*!
  Loads Notificatins API service interface
*/
void NotifHelper::initialize()
{
    qDebug() << "NotifHelper::initialize()";
    m_cancelled = false;
    QPluginLoader *loader = new QPluginLoader(ONE_PLUGIN_ABSOLUTE_PATH);

    if (loader) {
        qDebug() << "Plugin loaded";
        QObject *serviceObject = loader->instance();

        if (serviceObject) {
            qDebug() << "Plugin created";

            // Store the service interface for later usage
            m_notificationSession =
                    static_cast<OviNotificationSession*>(serviceObject);

            // Connect signals to slots
            connect(serviceObject, SIGNAL(stateChanged(QObject*)),
                    this, SLOT(changedState(QObject*)));
            connect(serviceObject, SIGNAL(received(QObject*)),
                    this, SLOT(notificationReceived(QObject*)));
        }
        else {
            qDebug() << "Creating plugin failed!";
            emit notificationError();
        }

        delete loader;
    }
}


/*!
  Listens Notifications API states
*/
void NotifHelper::changedState(QObject *aState)
{
    // State of the application has changed
    OviNotificationState *state =
            static_cast<OviNotificationState*>(aState);

    qDebug() << "OviNotificationState to : " << state->sessionState();

    if (m_cancelled) {
        qDebug() << "Cancelled!";
        emit busy(false);
        return;
    }

    // Print out the session state on the screen
    switch (state->sessionState()) {
    case OviNotificationState::EStateOffline: {
        emit busy(false);
        break;
    }
    case OviNotificationState::EStateOnline: {
        // Notifications API is online and activated

        qDebug() << "OviNotificationState to : " << "Notifications API is online and activated";

        // Set this application to be started when notification arrives
        m_notificationSession->setWakeUp(true);

        qDebug() << "getNotificationInformation";

        m_notificationSession->getNotificationInformation("service.aegis.co.id");

        // Is user wanted to API be activated or not?
        /*bool enabled = loadSetting("enabled",false).toBool();

        if (!enabled) {
            // User wants to notification to be disabled
            m_notificationSession->unregisterApplication();
        }*/
        emit busy(false);
        break;
    }
    case OviNotificationState::EStateConnecting: {
        emit busy(true);
        break;
    }
    default: {
        emit busy(false);
        break;
    }
    }

    if (state->sessionError() != OviNotificationState::EErrorNone) {
        qDebug() << "Error : " << state->sessionErrorString();
        emit busy(false);
    }

    delete state;
}


/*!
  Notification message received from Notifications API
*/
void NotifHelper::notificationReceived(QObject *aNotification)
{
    // Read received notification
    OviNotificationMessage *notification =
            static_cast<OviNotificationMessage*>(aNotification);
    OviNotificationPayload *payload =
            static_cast<OviNotificationPayload*>(notification->payload());

    //qDebug() << "payload: " << payload->dataString();

    //emit notificationReceived(payload->dataString());


    emit notify(payload->dataString());

    delete payload;
    delete notification;
}
