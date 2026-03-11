import QtQuick
import QtQuick.Controls
import "DMTheme.js" as DMTheme

Item {
    id: chrome

    property string themeName: (ApplicationWindow.window && ApplicationWindow.window.dmThemeName)
                               ? ApplicationWindow.window.dmThemeName
                               : "ocean"

    readonly property color mainBgTop: DMTheme.colorFor(themeName, "mainBgTop")
    readonly property color mainBgMid: DMTheme.colorFor(themeName, "mainBgMid")
    readonly property color mainBgBottom: DMTheme.colorFor(themeName, "mainBgBottom")
    readonly property color mainBlobTopRight: DMTheme.colorFor(themeName, "mainBlobTopRight")
    readonly property color mainBlobBottomLeft: DMTheme.colorFor(themeName, "mainBlobBottomLeft")

    readonly property color headerTop: DMTheme.colorFor(themeName, "headerTop")
    readonly property color headerBottom: DMTheme.colorFor(themeName, "headerBottom")
    readonly property color headerBorder: DMTheme.colorFor(themeName, "headerBorder")

    readonly property color menuButtonBorder: DMTheme.colorFor(themeName, "menuButtonBorder")
    readonly property color menuButtonBorderDown: DMTheme.colorFor(themeName, "menuButtonBorderDown")
    readonly property color menuButtonTop: DMTheme.colorFor(themeName, "menuButtonTop")
    readonly property color menuButtonTopDown: DMTheme.colorFor(themeName, "menuButtonTopDown")
    readonly property color menuButtonBottom: DMTheme.colorFor(themeName, "menuButtonBottom")
    readonly property color menuButtonBottomDown: DMTheme.colorFor(themeName, "menuButtonBottomDown")

    readonly property color titleText: DMTheme.colorFor(themeName, "titleText")

    readonly property color statusRunningTop: DMTheme.colorFor(themeName, "statusRunningTop")
    readonly property color statusRunningBottom: DMTheme.colorFor(themeName, "statusRunningBottom")
    readonly property color statusRunningBorder: DMTheme.colorFor(themeName, "statusRunningBorder")
    readonly property color statusIdleTop: DMTheme.colorFor(themeName, "statusIdleTop")
    readonly property color statusIdleBottom: DMTheme.colorFor(themeName, "statusIdleBottom")
    readonly property color statusIdleBorder: DMTheme.colorFor(themeName, "statusIdleBorder")
    readonly property color statusText: DMTheme.colorFor(themeName, "statusText")

    readonly property color drawerTop: DMTheme.colorFor(themeName, "drawerTop")
    readonly property color drawerBottom: DMTheme.colorFor(themeName, "drawerBottom")
    readonly property color drawerBorder: DMTheme.colorFor(themeName, "drawerBorder")
    readonly property color drawerOverlay: DMTheme.colorFor(themeName, "drawerOverlay")
    readonly property color drawerTitleText: DMTheme.colorFor(themeName, "drawerTitleText")
    readonly property color drawerSubtitleText: DMTheme.colorFor(themeName, "drawerSubtitleText")

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: chrome.mainBgTop }
            GradientStop { position: 0.48; color: chrome.mainBgMid }
            GradientStop { position: 1.0; color: chrome.mainBgBottom }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            width: parent.width * 0.55
            height: parent.height * 0.36
            radius: width * 0.5
            color: chrome.mainBlobTopRight
            transform: Rotation {
                origin.x: width * 0.5
                origin.y: height * 0.5
                angle: -18
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: parent.width * 0.6
            height: parent.height * 0.26
            radius: width * 0.5
            color: chrome.mainBlobBottomLeft
        }
    }
}
