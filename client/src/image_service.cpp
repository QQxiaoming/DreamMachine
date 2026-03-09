#include "image_service.h"
#include "mainwindow_utils.h"

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QImage>
#include <QImageReader>
#include <QJsonDocument>
#include <QPixmap>
#include <QSize>

bool ImageService::readImageSize(const QString &imagePath, int &width, int &height) const
{
    QImageReader reader(imagePath);
    const QSize size = reader.size();
    if (!size.isValid() || size.width() <= 0 || size.height() <= 0) {
        return false;
    }

    width = size.width();
    height = size.height();
    return true;
}

bool ImageService::buildPreviewPixmap(const QByteArray &imageBytes,
                                      QPixmap &pixmap,
                                      QString &error) const
{
    QImage image;
    if (!image.loadFromData(imageBytes)) {
        error = "Preview unavailable: cannot decode generated image.";
        return false;
    }

    pixmap = QPixmap::fromImage(image);
    if (pixmap.isNull()) {
        error = "Preview unavailable.";
        return false;
    }

    return true;
}

ImageService::SaveResult ImageService::saveGeneratedImage(const SaveRequest &request) const
{
    SaveResult result;

    if (request.imageBytes.isEmpty()) {
        result.error = "No generated image to save. Please run inference first.";
        return result;
    }
    if (request.outputDirPath.trimmed().isEmpty()) {
        result.error = "Please set output directory first.";
        return result;
    }

    QDir outputDir(request.outputDirPath.trimmed());
    if (!outputDir.exists() && !outputDir.mkpath(".")) {
        result.error = QString("Cannot create output directory: %1").arg(request.outputDirPath);
        return result;
    }

    const QString ext = extensionForFormat(request.outputFormat);
    const QString ts = QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss");
    QString fileName = QString("dreammachine_%1.%2").arg(ts, ext);
    QString filePath = outputDir.filePath(fileName);
    int counter = 1;
    while (QFileInfo::exists(filePath)) {
        fileName = QString("dreammachine_%1_%2.%3").arg(ts).arg(counter++).arg(ext);
        filePath = outputDir.filePath(fileName);
    }

    if (ext == "png") {
        QImage image;
        if (!image.loadFromData(request.imageBytes)) {
            result.error = "Cannot decode generated PNG for metadata embedding.";
            return result;
        }

        QJsonObject root;
        root["version"] = 1;
        QJsonObject preset = request.preset;
        preset["seed"] = QString::number(request.effectiveSeed);
        root["preset"] = preset;
        image.setText("dreammachine_preset_json", QString::fromUtf8(QJsonDocument(root).toJson(QJsonDocument::Compact)));

        if (!image.save(filePath, "PNG")) {
            result.error = QString("Failed to save PNG with metadata: %1").arg(filePath);
            return result;
        }
    } else {
        QFile outFile(filePath);
        if (!outFile.open(QIODevice::WriteOnly)) {
            result.error = QString("Cannot write file: %1").arg(filePath);
            return result;
        }

        if (outFile.write(request.imageBytes) != request.imageBytes.size()) {
            result.error = QString("Failed to write image data: %1").arg(filePath);
            return result;
        }
    }

    result.ok = true;
    result.filePath = filePath;
    return result;
}
