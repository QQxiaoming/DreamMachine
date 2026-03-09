#ifndef PRESET_STORAGE_H
#define PRESET_STORAGE_H

#include <QJsonObject>
#include <QString>

class PresetStorage
{
public:
    bool saveToFile(const QString &filePath, const QJsonObject &preset, QString &error) const;
    bool loadFromFile(const QString &filePath, QJsonObject &preset, QString &error) const;
};

#endif // PRESET_STORAGE_H
