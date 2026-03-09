#ifndef IMAGE_SERVICE_H
#define IMAGE_SERVICE_H

#include <QByteArray>
#include <QJsonObject>
#include <QString>
#include <QtGlobal>

class QSize;
class QPixmap;

class ImageService
{
public:
    struct SaveRequest {
        QByteArray imageBytes;
        QString outputFormat;
        QString outputDirPath;
        qint64 effectiveSeed = 0;
        QJsonObject preset;
    };

    struct SaveResult {
        bool ok = false;
        QString filePath;
        QString error;
    };

    bool readImageSize(const QString &imagePath, int &width, int &height) const;
    bool buildPreviewPixmap(const QByteArray &imageBytes,
                            QPixmap &pixmap,
                            QString &error) const;
    SaveResult saveGeneratedImage(const SaveRequest &request) const;
};

#endif // IMAGE_SERVICE_H
