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
        void (^requestBlock)(void) = ^{
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly
                                                       handler:^(PHAuthorizationStatus newStatus) {
                requestedStatus = newStatus;
                dispatch_semaphore_signal(semaphore);
            }];
        };

        if ([NSThread isMainThread]) {
            requestBlock();
        } else {
            dispatch_sync(dispatch_get_main_queue(), requestBlock);
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        return requestedStatus;
    }

    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusNotDetermined) {
        return status;
    }

    __block PHAuthorizationStatus requestedStatus = PHAuthorizationStatusNotDetermined;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    void (^requestBlock)(void) = ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus newStatus) {
            requestedStatus = newStatus;
            dispatch_semaphore_signal(semaphore);
        }];
    };

    if ([NSThread isMainThread]) {
        requestBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), requestBlock);
    }
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

void saveImageBytesToPhotoLibraryAsync(
    const QByteArray &imageBytes,
    std::function<void(const IosPhotoLibrarySaveResult &)> callback)
{
    if (!callback) {
        return;
    }

    const QByteArray imageBytesCopy = imageBytes;
    const auto callbackCopy = std::move(callback);

    auto deliverResult = [callbackCopy](const IosPhotoLibrarySaveResult &result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callbackCopy(result);
        });
    };

    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            if (imageBytesCopy.isEmpty()) {
                IosPhotoLibrarySaveResult result;
                result.error = "No generated image to save. Please run inference first.";
                deliverResult(result);
                return;
            }

            auto beginSave = [imageBytesCopy, deliverResult]() {
                NSData *imageData = [NSData dataWithBytes:imageBytesCopy.constData()
                                                   length:static_cast<NSUInteger>(imageBytesCopy.size())];
                if (imageData == nil || imageData.length == 0) {
                    IosPhotoLibrarySaveResult result;
                    result.error = "Cannot prepare image data for iOS Photos.";
                    deliverResult(result);
                    return;
                }

                __block NSString *localIdentifier = nil;
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                    [request addResourceWithType:PHAssetResourceTypePhoto data:imageData options:nil];
                    PHObjectPlaceholder *placeholder = request.placeholderForCreatedAsset;
                    if (placeholder != nil) {
                        localIdentifier = placeholder.localIdentifier;
                    }
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    IosPhotoLibrarySaveResult result;
                    if (!success) {
                        if (error != nil) {
                            result.error = QString("Failed to save image to iOS Photos: %1")
                                               .arg(nsStringToQString(error.localizedDescription));
                        } else {
                            result.error = "Failed to save image to iOS Photos.";
                        }
                    } else {
                        result.ok = true;
                        result.assetLocalIdentifier = nsStringToQString(localIdentifier);
                    }
                    if (!result.ok && result.error.isEmpty()) {
                        result.error = QString("Failed to save image to iOS Photos: %1")
                                           .arg("Unknown error");
                    }
                    deliverResult(result);
                }];
            };

            if (@available(iOS 14, *)) {
                const PHAuthorizationStatus status =
                    [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelAddOnly];
                if (status == PHAuthorizationStatusNotDetermined) {
                    [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly
                                                               handler:^(PHAuthorizationStatus newStatus) {
                        if (isPhotoPermissionGranted(newStatus)) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                beginSave();
                            });
                        } else {
                            IosPhotoLibrarySaveResult result;
                            result.error = permissionStatusToError(newStatus);
                            deliverResult(result);
                        }
                    }];
                    return;
                }

                if (!isPhotoPermissionGranted(status)) {
                    IosPhotoLibrarySaveResult result;
                    result.error = permissionStatusToError(status);
                    deliverResult(result);
                    return;
                }

                beginSave();
                return;
            }

            const PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == PHAuthorizationStatusNotDetermined) {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus newStatus) {
                    if (isPhotoPermissionGranted(newStatus)) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            beginSave();
                        });
                    } else {
                        IosPhotoLibrarySaveResult result;
                        result.error = permissionStatusToError(newStatus);
                        deliverResult(result);
                    }
                }];
                return;
            }

            if (!isPhotoPermissionGranted(status)) {
                IosPhotoLibrarySaveResult result;
                result.error = permissionStatusToError(status);
                deliverResult(result);
                return;
            }

            beginSave();
        }
    });
}

IosPhotoLibrarySaveResult saveImageBytesToPhotoLibrary(const QByteArray &imageBytes)
{
    __block IosPhotoLibrarySaveResult finalResult;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    saveImageBytesToPhotoLibraryAsync(
        imageBytes,
        [&](const IosPhotoLibrarySaveResult &result) {
            finalResult = result;
            dispatch_semaphore_signal(semaphore);
        });

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return finalResult;
}
