/**
 * Copyright (c) 2011 Nokia Corporation.
 */

// Own header
#include "transferuitransferitem.h"

// Harmattan includes
#include <TransferUI/Client>
#include <TransferUI/Transfer>

// transferuiexample includes
#include "transferuiclientitem.h"


using namespace TransferUI;


/*!
  \class TransferUITransferItem
  \brief QML Wrapper for TransferUI::Transfer instance.
  \see http://harmattan-dev.nokia.com/docs/library/html/transfer-ui/classTransferUI_1_1Transfer.html
*/



/*!
  Constructor.
*/
TransferUITransferItem::TransferUITransferItem(QDeclarativeItem *parent)
    : QDeclarativeItem(parent),
      m_transfer(0),
      m_clientItem(0),
      m_size(0),
      m_showInHistory(false),
      m_estimate(0),
      m_progress(0.0f)
{
}


/*!
  Destructor.
*/
TransferUITransferItem::~TransferUITransferItem()
{
    // Remove and delete the transfer instance if one exists.
    remove();
}


/*!
  Sets the client. In order to register this transfer, client has to be set.
*/
void TransferUITransferItem::setClient(QObject *client)
{
    m_clientItem = qobject_cast<TransferUIClientItem*>(client);

    if (m_clientItem) {
        connect(m_clientItem, SIGNAL(transferCancelled(Transfer*)),
                this, SLOT(transferCancelled(Transfer*)));
        connect(m_clientItem, SIGNAL(transferPaused(Transfer*)),
                this, SLOT(transferPaused(Transfer*)));
        connect(m_clientItem, SIGNAL(transferStarted(Transfer*)),
                this, SLOT(transferStarted(Transfer*)));
    }
}


/*!
  Returns the client item.
*/
QObject *TransferUITransferItem::client() const
{
    return m_clientItem;
}


/*!
  \see TransferUI::Transfer documentation
*/
void TransferUITransferItem::setIconId(QString iconId)
{
    m_iconId = iconId;
}


/*!
  Returns the icon ID.
*/
QString TransferUITransferItem::iconId() const
{
    return m_iconId;
}


/*!
  \see TransferUI::Transfer documentation
*/
void TransferUITransferItem::setName(QString name)
{
    m_name = name;
}


/*!
  Returns the name of the transfer.
*/
QString TransferUITransferItem::name() const
{
    return m_name;
}


/*!
  \see TransferUI::Transfer documentation
*/
void TransferUITransferItem::setTargetName(QString targetName)
{
    m_targetName = targetName;
}


/*!
  Returns the target name of the transfer.
*/
QString TransferUITransferItem::targetName() const
{
    return m_targetName;
}


/*!
  \see TransferUI::Transfer documentation
*/
void TransferUITransferItem::setSize(quint32 size)
{
    m_size = size;
}


/*!
  Returns the size of the transfer.
*/
quint32 TransferUITransferItem::size() const
{
    return m_size;
}


/*!
  Sets the transfer instance. The previous transfer is removed from the client
  and deleted.
*/
void TransferUITransferItem::setTransfer(QObject *transfer)
{
    // Remove and delete the prevous transfer if one exists.
    remove();

    // Set the new transfer.
    m_transfer = qobject_cast<Transfer*>(transfer);

    if (m_transfer) {
        // Re-route signals.
        connect(m_transfer, SIGNAL(cancel()), this, SIGNAL(cancelled()));
        connect(m_transfer, SIGNAL(pause()), this, SLOT(paused()));
        connect(m_transfer, SIGNAL(start()), this, SIGNAL(started()));
    }
}


/*!
  Returns the transfer instance.
*/
QObject *TransferUITransferItem::transfer() const
{
    return m_transfer;
}


/*!
  If \a show is true, the transfer will be shown in history after completion.
*/
void TransferUITransferItem::setShowInHistory(bool show)
{
    m_showInHistory = show;
}


/*!
  Returns true if the transfer will be shown in history after completion.
  False otherwise.
*/
bool TransferUITransferItem::showInHistory() const
{
    return m_showInHistory;
}


/*!
  Sets the estimate to \a seconds.
*/
void TransferUITransferItem::setEstimate(int seconds)
{
    m_estimate = seconds;
}


/*!
  Returns the estimate.
*/
int TransferUITransferItem::estimate() const
{
    return m_estimate;
}


/*!
  Sets the progress to \a done.
*/
void TransferUITransferItem::setProgress(float done)
{
    if (m_progress != done) {
        m_progress = done;
        emit progressChanged(m_progress);
    }
}


/*!
  Returns the progress.
*/
float TransferUITransferItem::progress() const
{
    return m_progress;
}


/*!
  Registers this transfer to the client. The actual registration is done by
  TransferUI::Client instance. See TransferUI::Client documentation for further
  information.

  Returns true if successful, false otherwise.
*/
bool TransferUITransferItem::registerTransfer(const QString &name,
                                              /*TransferType*/ int type,
                                              const QString &clientId)
{
    // Remove and delete the previous transfer if one exists.
    remove();

    if (m_clientItem) {
        qDebug() << "TransferUITransferItem::registerTransfer():"
                 << name << type << clientId;
        QString theClientId = QString();

        if (!clientId.isEmpty()) {
            theClientId = clientId;
        }

        Client *client = m_clientItem->clientInstance();
        m_transfer = client->registerTransfer(name,
                                              (Client::TransferType)type,
                                              theClientId);
        return commit();
    }

    qDebug() << "TransferUITransferItem::registerTransfer(): No client set!";
    return false;
}


/*!
  Commits the set transfer properties. Returns true if successful,
  false otherwise.
*/
bool TransferUITransferItem::commit()
{
    if (!m_transfer) {
        qDebug() << "TransferUITransferItem::commit(): No transfer instance!";
        return false;
    }

    m_transfer->waitForCommit();

    m_transfer->setIcon(m_iconId);
    m_transfer->setName(m_name);
    m_transfer->setTargetName(m_targetName);
    m_transfer->setSize(m_size);
    m_transfer->setEstimate(m_estimate);
    m_transfer->setProgress(m_progress);

    m_transfer->commit();
    return true;
}


/*!
  Removes the transfer from the client item. Returns true if removed, false
  otherwise.
*/
bool TransferUITransferItem::remove()
{
    bool retval(false);

    if (m_clientItem && m_transfer) {
        m_clientItem->removeTransfer(m_transfer->transferId());
        retval = true;
    }

    delete m_transfer;
    m_transfer = 0;

    return retval;
}


/*!
  \see TransferUI::Transfer documentation
*/
bool TransferUITransferItem::markCancelFailed()
{
    return m_transfer->markCancelFailed("message");
}


/*!
  \see TransferUI::Transfer documentation
*/
bool TransferUITransferItem::markCancelled()
{
    return m_transfer->markCancelled();
}


/*!
  \see TransferUI::Transfer documentation
*/
bool TransferUITransferItem::markCompleted()
{
    return m_transfer->markCompleted(m_showInHistory);
}


/*!
  \see TransferUI::Transfer documentation
*/
bool TransferUITransferItem::markDone()
{
    return m_transfer->markDone("message");
}


/*!
  \see TransferUI::Transfer documentation
*/
bool TransferUITransferItem::markFailure()
{
    return m_transfer->markFailure("header message", "description");
}


/*!
  \see TransferUI::Transfer documentation
*/
bool TransferUITransferItem::markPaused()
{
    return m_transfer->markPaused();
}


/*!
  \see TransferUI::Transfer documentation
*/
bool TransferUITransferItem::markResumed()
{
    return m_transfer->markResumed();
}


/*!
  \see TransferUI::Transfer documentation
*/
bool TransferUITransferItem::setActive()
{
    qDebug() << "TransferUITransferItem::setActive():" << m_progress;
    return m_transfer->setActive(m_progress);
}


/*!
  \see TransferUI::Transfer documentation
*/
bool TransferUITransferItem::setPending()
{
    return m_transfer->setPending("reason");
}


/*!
  This private slot is connected to a signal of the client.
*/
void TransferUITransferItem::transferCancelled(Transfer *transfer)
{
    if (transfer == m_transfer) {
        emit cancelled();
    }
}


/*!
  This private slot is connected to a signal of the client.
*/
void TransferUITransferItem::transferPaused(Transfer *transfer)
{
    if (transfer == m_transfer) {
        emit paused();
    }
}


/*!
  This private slot is connected to a signal of the client.
*/
void TransferUITransferItem::transferStarted(Transfer *transfer)
{
    if (transfer == m_transfer) {
        emit started();
    }
}


QML_DECLARE_TYPE(TransferUITransferItem)

// End of file.
