import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "DMTheme.js" as DMTheme

Button {
    id: control

    property bool primary: false
    property bool danger: false
    property bool compact: false
    property string themeName: ""
    readonly property string dmThemeName: themeName.length > 0
                                          ? themeName
                                          : ((ApplicationWindow.window && ApplicationWindow.window.dmThemeName)
                                             ? ApplicationWindow.window.dmThemeName
                                             : "ocean")

    implicitHeight: compact ? 34 : 42
    implicitWidth: Math.max(compact ? 90 : 112, contentItem.implicitWidth + leftPadding + rightPadding)
    leftPadding: compact ? 12 : 16
    rightPadding: compact ? 12 : 16
    topPadding: compact ? 6 : 8
    bottomPadding: compact ? 6 : 8

    font.pixelSize: compact ? 12 : 14
    font.bold: true
    font.family: Qt.platform.os === "ios" ? "Avenir Next" : "Noto Sans"

    scale: control.down ? 0.98 : 1.0
    opacity: control.enabled ? 1.0 : 0.55

    Behavior on scale {
        NumberAnimation {
            duration: 90
            easing.type: Easing.OutCubic
        }
    }

    contentItem: Text {
        text: control.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: DMTheme.colorFor(control.dmThemeName, "buttonText")
        font: control.font
        elide: Text.ElideRight
    }

    background: Rectangle {
        id: bg
        radius: control.compact ? 11 : 13
        border.width: 1
        border.color: DMTheme.buttonBorderFor(control.dmThemeName,
                                              control.enabled,
                                              control.primary,
                                              control.danger,
                                              control.down)

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: DMTheme.buttonTopFor(control.dmThemeName,
                                            control.enabled,
                                            control.primary,
                                            control.danger,
                                            control.down)
            }
            GradientStop {
                position: 1.0
                color: DMTheme.buttonBottomFor(control.dmThemeName,
                                               control.enabled,
                                               control.primary,
                                               control.danger,
                                               control.down)
            }
        }
    }
}
