#ifndef INILAHSVC_H
#define INILAHSVC_H

#include <QObject>
class NetAccessMan;

class StandardSvc : public QObject
{
    Q_OBJECT
public:
    explicit StandardSvc(QObject *parent = 0);

public slots:
    QString toGMTPlus7(const QString & date);
    void share(QString title, QString url);

};

#endif // INILAHSVC_H
