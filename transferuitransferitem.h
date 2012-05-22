/**
 * Copyright (c) 2011 Nokia Corporation.
 */

#ifndef TRANSFERUITRANSFERITEM_H
#define TRANSFERUITRANSFERITEM_H

// Qt includes
#include <QDeclarativeItem>

// Harmattan includes
#include <TransferUI/TransferEnums>


namespace TransferUI {

// Forward declarations
class Transfer;
class TransferUIClientItem;


class TransferUITransferItem : public QDeclarativeItem
{
    Q_OBJECT
    Q_ENUMS(TransferType) // From TransferUI/TransferEnums
    Q_PROPERTY(QObject* client READ client WRITE setClient)
    Q_PROPERTY(QObject* transfer READ transfer WRITE setTransfer)
    Q_PROPERTY(QString iconId READ iconId WRITE setIconId)
    Q_PROPERTY(QString name READ name WRITE setName)
    Q_PROPERTY(QString targetName READ targetName WRITE setTargetName)
    Q_PROPERTY(quint32 size READ size WRITE setSize)
    Q_PROPERTY(bool showInHistory READ showInHistory WRITE setShowInHistory)
    Q_PROPERTY(int estimate READ estimate WRITE setEstimate)
    Q_PROPERTY(float progress READ progress WRITE setProgress NOTIFY progressChanged)

public:
    explicit TransferUITransferItem(QDeclarativeItem *parent = 0);
    virtual ~TransferUITransferItem();

public: // Property setters/getters
    void setClient(QObject *client);
    QObject *client() const;
    void setIconId(QString iconId);
    QString iconId() const;
    void setName(QString name);
    QString name() const;
    void setTargetName(QString targetName);
    QString targetName() const;
    void setSize(quint32 size);
    quint32 size() const;
    void setTransfer(QObject *transfer);
    QObject *transfer() const;
    void setShowInHistory(bool show);
    bool showInHistory() const;
    void setEstimate(int seconds);
    int estimate() const;
    void setProgress(float done);
    float progress() const;

public slots:
    bool registerTransfer(const QString &name,
                          /*TransferType*/ int type,
                          const QString &clientId /* = QString() */); // QML cannot handle method overloading
    bool commit();
    bool remove();
    bool markCancelFailed();
    bool markCancelled();
    bool markCompleted();
    bool markDone();
    bool markFailure();
    bool markPaused();
    bool markResumed();
    bool setActive();
    bool setPending();

private slots: // The following slots are connected to signals of the client
    void transferCancelled(Transfer *transfer);
    void transferPaused(Transfer *transfer);
    void transferStarted(Transfer *transfer);

signals:
    void progressChanged(float done);
    void cancelled();
    void paused();
    void started();

private: // Data
    Transfer *m_transfer; // Owned
    TransferUIClientItem *m_clientItem; // Not owned
    QString m_iconId;
    QString m_name;
    QString m_targetName;
    quint32 m_size;
    bool m_showInHistory;
    int m_estimate;
    float m_progress;
};

} // namespace TransferUI


#endif // TRANSFERUITRANSFERITEM_H

// End of file.
