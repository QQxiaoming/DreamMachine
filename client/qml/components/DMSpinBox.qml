import QtQuick
import QtQuick.Controls
import "DMTheme.js" as DMTheme

SpinBox {
    id: control

    implicitWidth: 118
    implicitHeight: 42
    editable: true
    leftPadding: 38
    rightPadding: 38

    topPadding: 4
    bottomPadding: 4

    font.pixelSize: 14
    font.family: Qt.platform.os === "ios" ? "Avenir Next" : "Noto Sans"

    contentItem: TextInput {
        z: 2
        anchors.fill: parent
        anchors.leftMargin: control.leftPadding
        anchors.rightMargin: control.rightPadding
        anchors.topMargin: control.topPadding
        anchors.bottomMargin: control.bottomPadding
        text: control.displayText
        font: control.font
        color: DMTheme.fieldText(control.enabled)
        selectionColor: DMTheme.color("fieldSelection")
        selectedTextColor: DMTheme.color("fieldSelectedText")
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly

        onTextEdited: function() {
            control.value = control.valueFromText(text, control.locale)
        }
    }

    background: Rectangle {
        radius: 12
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? DMTheme.color("fieldBorderFocus") : DMTheme.color("fieldBorder")
        gradient: Gradient {
            GradientStop { position: 0.0; color: DMTheme.color("fieldBgTop") }
            GradientStop { position: 1.0; color: DMTheme.color("fieldBgBottom") }
        }
    }

    down.indicator: Rectangle {
        z: 3
        x: 4
        y: 4
        width: 30
        height: control.height - 8
        radius: 10
        border.width: 1
                border.color: DMTheme.spinIndicatorBorder(control.enabled, control.down.pressed)
        gradient: Gradient {
            GradientStop {
                position: 0.0
                                color: DMTheme.spinIndicatorTop(control.enabled, control.down.pressed)
            }
            GradientStop {
                position: 1.0
                                color: DMTheme.spinIndicatorBottom(control.enabled, control.down.pressed)
            }
        }

        Text {
            anchors.centerIn: parent
            text: "-"
            color: DMTheme.color("spinIndicatorText")
            font.pixelSize: 18
            font.bold: true
        }
    }

    up.indicator: Rectangle {
        z: 3
        x: control.width - width - 4
        y: 4
        width: 30
        height: control.height - 8
        radius: 10
        border.width: 1
                border.color: DMTheme.spinIndicatorBorder(control.enabled, control.up.pressed)
        gradient: Gradient {
            GradientStop {
                position: 0.0
                                color: DMTheme.spinIndicatorTop(control.enabled, control.up.pressed)
            }
            GradientStop {
                position: 1.0
                                color: DMTheme.spinIndicatorBottom(control.enabled, control.up.pressed)
            }
        }

        Text {
            anchors.centerIn: parent
            text: "+"
            color: DMTheme.color("spinIndicatorText")
            font.pixelSize: 17
            font.bold: true
        }
    }
}
