#include "ios_photo_library.h"

#include <utility>

IosPhotoLibrarySaveResult saveImageBytesToPhotoLibrary(const QByteArray &imageBytes)
{
    (void)imageBytes;

    IosPhotoLibrarySaveResult result;
    result.error = "Saving to iOS Photos is only available in iOS builds.";
    return result;
}

void saveImageBytesToPhotoLibraryAsync(
    const QByteArray &imageBytes,
    std::function<void(const IosPhotoLibrarySaveResult &)> callback)
{
    if (!callback) {
        return;
    }

    callback(saveImageBytesToPhotoLibrary(imageBytes));
}
