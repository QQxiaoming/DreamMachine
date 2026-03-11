import QtQuick
import "DMTheme.js" as DMTheme

QtObject {
    id: chrome

    property string themeName: "ocean"

    readonly property color surfaceBorder: DMTheme.colorFor(themeName, "previewSurfaceBorder")
    readonly property color surfaceTop: DMTheme.colorFor(themeName, "previewSurfaceTop")
    readonly property color surfaceBottom: DMTheme.colorFor(themeName, "previewSurfaceBottom")

    readonly property color badgeBorder: DMTheme.colorFor(themeName, "previewBadgeBorder")
    readonly property color badgeTop: DMTheme.colorFor(themeName, "previewBadgeTop")
    readonly property color badgeBottom: DMTheme.colorFor(themeName, "previewBadgeBottom")
    readonly property color badgeText: DMTheme.colorFor(themeName, "previewBadgeText")

    readonly property color hintText: DMTheme.colorFor(themeName, "previewHintText")
    readonly property color indicatorActive: DMTheme.colorFor(themeName, "previewIndicatorActive")
    readonly property color indicatorInactive: DMTheme.colorFor(themeName, "previewIndicatorInactive")
    readonly property color errorText: DMTheme.colorFor(themeName, "previewErrorText")

    readonly property color fullscreenOverlay: DMTheme.colorFor(themeName, "previewFullscreenOverlay")
    readonly property color fullscreenHint: DMTheme.colorFor(themeName, "previewFullscreenHint")
}
