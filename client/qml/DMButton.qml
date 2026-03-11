import QtQuick
import QtQuick.Controls

Button {
    id: control

    property bool primary: false
    property bool danger: false
    property bool compact: false

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
        color: "#f2f7fd"
        font: control.font
        elide: Text.ElideRight
    }

    background: Rectangle {
        id: bg
        radius: control.compact ? 11 : 13
        border.width: 1
        border.color: !control.enabled
                      ? "#44617a"
                      : control.primary
                        ? (control.down ? "#66f8d2" : "#4be8c1")
                        : control.danger
                          ? (control.down ? "#ff8a96" : "#ff6e7d")
                          : (control.down ? "#6c88a3" : "#56748f")

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: !control.enabled
                       ? "#2f4356"
                       : control.primary
                         ? (control.down ? "#117b69" : "#15927d")
                         : control.danger
                           ? (control.down ? "#8e2f40" : "#a6384c")
                           : (control.down ? "#2d4962" : "#375875")
            }
            GradientStop {
                position: 1.0
                color: !control.enabled
                       ? "#27394a"
                       : control.primary
                         ? (control.down ? "#0e6558" : "#127565")
                         : control.danger
                           ? (control.down ? "#772636" : "#8f3042")
                           : (control.down ? "#273f56" : "#2f4c66")
            }
        }
    }
}
