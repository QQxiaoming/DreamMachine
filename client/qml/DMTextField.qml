import QtQuick
import QtQuick.Controls

TextField {
    id: control

    implicitHeight: 42
    leftPadding: 12
    rightPadding: 12
    topPadding: 9
    bottomPadding: 9

    color: enabled ? "#edf4fd" : "#9cb2c6"
    selectionColor: "#2aa58a"
    selectedTextColor: "#ffffff"
    placeholderTextColor: "#7f99af"

    font.pixelSize: 14
    font.family: Qt.platform.os === "ios" ? "Avenir Next" : "Noto Sans"

    background: Rectangle {
        radius: 12
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? "#4fe3be" : "#3f5e79"
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#162838" }
            GradientStop { position: 1.0; color: "#112131" }
        }
    }
}
