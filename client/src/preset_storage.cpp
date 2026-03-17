#include "preset_storage.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QImage>
#include <QImageReader>
#include <QJsonDocument>
#include <QJsonParseError>

namespace {

QJsonObject extractPresetObject(const QJsonObject &root)
{
    return root.value("preset").isObject() ? root.value("preset").toObject() : root;
}

} // namespace

bool PresetStorage::saveToFile(const QString &filePath, const QJsonObject &preset, QString &error) const
{
    QJsonObject root;
    root["version"] = 1;
    root["preset"] = preset;

    const QFileInfo fileInfo(filePath);
    const QString directoryPath = fileInfo.absolutePath();
    if (!directoryPath.isEmpty()) {
        QDir dir;
        if (!dir.mkpath(directoryPath)) {
            error = QString("Cannot create preset directory: %1").arg(directoryPath);
            return false;
        }
    }

    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        error = QString("Cannot open file for writing: %1 (%2)").arg(filePath, file.errorString());
        return false;
    }

    const QByteArray data = QJsonDocument(root).toJson(QJsonDocument::Indented);
    if (file.write(data) != data.size()) {
        error = QString("Failed to write preset file: %1 (%2)").arg(filePath, file.errorString());
        return false;
    }

    return true;
}

bool PresetStorage::loadFromFile(const QString &filePath, QJsonObject &preset, QString &error) const
{
    QJsonObject root;
    const QString suffix = QFileInfo(filePath).suffix().toLower();

    if (suffix == "png") {
        QImageReader reader(filePath);
        const QImage image = reader.read();
        if (image.isNull()) {
            error = QString("Cannot read PNG file: %1").arg(filePath);
            return false;
        }

        const QString presetJson = image.text("dreammachine_preset_json").trimmed();
        if (presetJson.isEmpty()) {
            error = "PNG does not contain embedded preset JSON.";
            return false;
        }

        QJsonParseError parseError;
        const QJsonDocument doc = QJsonDocument::fromJson(presetJson.toUtf8(), &parseError);
        if (parseError.error != QJsonParseError::NoError || !doc.isObject()) {
            error = QString("Embedded preset JSON is invalid: %1").arg(parseError.errorString());
            return false;
        }
        root = doc.object();
    } else {
        QFile file(filePath);
        if (!file.open(QIODevice::ReadOnly)) {
            error = QString("Cannot open file: %1").arg(filePath);
            return false;
        }

        QJsonParseError parseError;
        const QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);
        if (parseError.error != QJsonParseError::NoError || !doc.isObject()) {
            error = QString("Invalid preset JSON: %1").arg(parseError.errorString());
            return false;
        }
        root = doc.object();
    }

    preset = extractPresetObject(root);
    return true;
}
