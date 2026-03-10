#ifndef IOS_PHOTO_LIBRARY_H
#define IOS_PHOTO_LIBRARY_H

#include <QByteArray>
#include <QString>

struct IosPhotoLibrarySaveResult
{
    bool ok = false;
    QString assetLocalIdentifier;
    QString error;
};

IosPhotoLibrarySaveResult saveImageBytesToPhotoLibrary(const QByteArray &imageBytes);

#endif // IOS_PHOTO_LIBRARY_H
