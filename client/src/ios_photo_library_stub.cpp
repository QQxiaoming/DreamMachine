#include "ios_photo_library.h"

IosPhotoLibrarySaveResult saveImageBytesToPhotoLibrary(const QByteArray &imageBytes)
{
    (void)imageBytes;

    IosPhotoLibrarySaveResult result;
    result.error = "Saving to iOS Photos is only available in iOS builds.";
    return result;
}
