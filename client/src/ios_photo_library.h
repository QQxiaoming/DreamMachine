#ifndef IOS_PHOTO_LIBRARY_H
#define IOS_PHOTO_LIBRARY_H

#include <functional>

#include <QByteArray>
#include <QString>

struct IosPhotoLibrarySaveResult
{
    bool ok = false;
    QString assetLocalIdentifier;
    QString error;
};

IosPhotoLibrarySaveResult saveImageBytesToPhotoLibrary(const QByteArray &imageBytes);
void saveImageBytesToPhotoLibraryAsync(
    const QByteArray &imageBytes,
    std::function<void(const IosPhotoLibrarySaveResult &)> callback);

#endif // IOS_PHOTO_LIBRARY_H
