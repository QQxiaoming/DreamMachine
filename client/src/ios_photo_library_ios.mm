#include "ios_photo_library.h"

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

#include <dispatch/dispatch.h>

namespace {

QString nsStringToQString(NSString *value)
{
    if (value == nil) {
        return QString();
    }
    return QString::fromUtf8(value.UTF8String);
}

PHAuthorizationStatus requestPhotoLibraryAddPermission()
{
    if (@available(iOS 14, *)) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelAddOnly];
        if (status != PHAuthorizationStatusNotDetermined) {
            return status;
        }

        __block PHAuthorizationStatus requestedStatus = PHAuthorizationStatusNotDetermined;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly
                                                   handler:^(PHAuthorizationStatus newStatus) {
            requestedStatus = newStatus;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        return requestedStatus;
    }

    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusNotDetermined) {
        return status;
    }

    __block PHAuthorizationStatus requestedStatus = PHAuthorizationStatusNotDetermined;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus newStatus) {
        requestedStatus = newStatus;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return requestedStatus;
}

bool isPhotoPermissionGranted(PHAuthorizationStatus status)
{
    return status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited;
}

QString permissionStatusToError(PHAuthorizationStatus status)
{
    switch (status) {
    case PHAuthorizationStatusDenied:
        return "Photo library permission denied. Please allow photo access in iOS Settings.";
    case PHAuthorizationStatusRestricted:
        return "Photo library permission is restricted on this device.";
    case PHAuthorizationStatusNotDetermined:
        return "Photo library permission request did not complete.";
    default:
        return "Photo library permission is not granted.";
    }
}

} // namespace

IosPhotoLibrarySaveResult saveImageBytesToPhotoLibrary(const QByteArray &imageBytes)
{
    IosPhotoLibrarySaveResult result;

    if (imageBytes.isEmpty()) {
        result.error = "No generated image to save. Please run inference first.";
        return result;
    }

    const PHAuthorizationStatus authorization = requestPhotoLibraryAddPermission();
    if (!isPhotoPermissionGranted(authorization)) {
        result.error = permissionStatusToError(authorization);
        return result;
    }

    NSData *imageData = [NSData dataWithBytes:imageBytes.constData()
                                       length:static_cast<NSUInteger>(imageBytes.size())];
    if (imageData == nil || imageData.length == 0) {
        result.error = "Cannot prepare image data for iOS Photos.";
        return result;
    }

    __block NSError *saveError = nil;
    __block NSString *localIdentifier = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        [request addResourceWithType:PHAssetResourceTypePhoto data:imageData options:nil];
        PHObjectPlaceholder *placeholder = request.placeholderForCreatedAsset;
        if (placeholder != nil) {
            localIdentifier = placeholder.localIdentifier;
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (!success && error != nil) {
            saveError = error;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    if (saveError != nil) {
        result.error = QString("Failed to save image to iOS Photos: %1")
                           .arg(nsStringToQString(saveError.localizedDescription));
        return result;
    }

    result.ok = true;
    result.assetLocalIdentifier = nsStringToQString(localIdentifier);
    return result;
}
