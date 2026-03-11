import QtQuick
import QtQuick.Controls

Slider {
    id: control

    implicitHeight: 30
    padding: 0

    background: Item {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: control.availableWidth
        height: 8

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            border.width: 1
            border.color: "#42617d"
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1b3145" }
                GradientStop { position: 1.0; color: "#172b3d" }
            }
        }

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: height / 2
            border.width: 1
            border.color: "#71e9c8"
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#179a83" }
                GradientStop { position: 1.0; color: "#127966" }
            }
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 20
        height: 20
        radius: 10
        border.width: 1
        border.color: control.pressed ? "#9ef6de" : "#6bd8bc"
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: control.pressed ? "#3ec6a8" : "#2fb695"
            }
            GradientStop {
                position: 1.0
                color: control.pressed ? "#2da286" : "#268d74"
            }
        }
        scale: control.pressed ? 1.08 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 90
                easing.type: Easing.OutCubic
            }
        }
    }
}
