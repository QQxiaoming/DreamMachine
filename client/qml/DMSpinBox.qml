import QtQuick
import QtQuick.Controls

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
        color: control.enabled ? "#edf4fd" : "#9cb2c6"
        selectionColor: "#2aa58a"
        selectedTextColor: "#ffffff"
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
        border.color: control.activeFocus ? "#4fe3be" : "#3f5e79"
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#162838" }
            GradientStop { position: 1.0; color: "#112131" }
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
        border.color: control.down.pressed ? "#6bb4e3" : "#4c789a"
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: !control.enabled
                       ? "#2f4356"
                       : control.down.pressed
                         ? "#2b5c7f"
                         : "#35688d"
            }
            GradientStop {
                position: 1.0
                color: !control.enabled
                       ? "#27394a"
                       : control.down.pressed
                         ? "#224b68"
                         : "#2a5674"
            }
        }

        Text {
            anchors.centerIn: parent
            text: "-"
            color: "#eff6ff"
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
        border.color: control.up.pressed ? "#6bb4e3" : "#4c789a"
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: !control.enabled
                       ? "#2f4356"
                       : control.up.pressed
                         ? "#2b5c7f"
                         : "#35688d"
            }
            GradientStop {
                position: 1.0
                color: !control.enabled
                       ? "#27394a"
                       : control.up.pressed
                         ? "#224b68"
                         : "#2a5674"
            }
        }

        Text {
            anchors.centerIn: parent
            text: "+"
            color: "#eff6ff"
            font.pixelSize: 17
            font.bold: true
        }
    }
}
