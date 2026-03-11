import QtQuick
import QtQuick.Controls
import "DMTheme.js" as DMTheme

TextArea {
    id: control

    leftPadding: 12
    rightPadding: 12
    topPadding: 10
    bottomPadding: 10

    color: DMTheme.fieldText(enabled)
    selectionColor: DMTheme.color("fieldSelection")
    selectedTextColor: DMTheme.color("fieldSelectedText")
    placeholderTextColor: DMTheme.color("fieldPlaceholder")

    font.pixelSize: 14
    font.family: Qt.platform.os === "ios" ? "Avenir Next" : "Noto Sans"

    background: Rectangle {
        radius: 12
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? DMTheme.color("fieldBorderFocus") : DMTheme.color("fieldBorder")
        gradient: Gradient {
            GradientStop { position: 0.0; color: DMTheme.color("fieldBgTop") }
            GradientStop { position: 1.0; color: DMTheme.color("fieldBgBottom") }
        }
    }
}
