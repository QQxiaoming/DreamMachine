import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "DMTheme.js" as DMTheme

TextArea {
    id: control
    property string themeName: ""
    readonly property string dmThemeName: themeName.length > 0
                                          ? themeName
                                          : ((ApplicationWindow.window && ApplicationWindow.window.dmThemeName)
                                             ? ApplicationWindow.window.dmThemeName
                                             : "ocean")

    leftPadding: 12
    rightPadding: 12
    topPadding: 10
    bottomPadding: 10

    color: DMTheme.fieldTextFor(control.dmThemeName, enabled)
    selectionColor: DMTheme.colorFor(control.dmThemeName, "fieldSelection")
    selectedTextColor: DMTheme.colorFor(control.dmThemeName, "fieldSelectedText")
    placeholderTextColor: DMTheme.colorFor(control.dmThemeName, "fieldPlaceholder")

    font.pixelSize: 14
    font.family: Qt.platform.os === "ios" ? "Avenir Next" : "Noto Sans"

    background: Rectangle {
        radius: 12
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus
                      ? DMTheme.colorFor(control.dmThemeName, "fieldBorderFocus")
                      : DMTheme.colorFor(control.dmThemeName, "fieldBorder")
        gradient: Gradient {
            GradientStop { position: 0.0; color: DMTheme.colorFor(control.dmThemeName, "fieldBgTop") }
            GradientStop { position: 1.0; color: DMTheme.colorFor(control.dmThemeName, "fieldBgBottom") }
        }
    }
}
