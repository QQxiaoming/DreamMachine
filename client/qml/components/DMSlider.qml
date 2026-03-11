import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "DMTheme.js" as DMTheme

Slider {
    id: control
    readonly property string dmThemeName: (ApplicationWindow.window && ApplicationWindow.window.dmThemeName)
                                          ? ApplicationWindow.window.dmThemeName
                                          : "ocean"

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
            border.color: DMTheme.colorFor(control.dmThemeName, "sliderTrackBorder")
            gradient: Gradient {
                GradientStop { position: 0.0; color: DMTheme.colorFor(control.dmThemeName, "sliderTrackTop") }
                GradientStop { position: 1.0; color: DMTheme.colorFor(control.dmThemeName, "sliderTrackBottom") }
            }
        }

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: height / 2
            border.width: 1
            border.color: DMTheme.colorFor(control.dmThemeName, "sliderFillBorder")
            gradient: Gradient {
                GradientStop { position: 0.0; color: DMTheme.colorFor(control.dmThemeName, "sliderFillTop") }
                GradientStop { position: 1.0; color: DMTheme.colorFor(control.dmThemeName, "sliderFillBottom") }
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
        border.color: DMTheme.sliderHandleBorderFor(control.dmThemeName, control.pressed)
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: DMTheme.sliderHandleTopFor(control.dmThemeName, control.pressed)
            }
            GradientStop {
                position: 1.0
                color: DMTheme.sliderHandleBottomFor(control.dmThemeName, control.pressed)
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
