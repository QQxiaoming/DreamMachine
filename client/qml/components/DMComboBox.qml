import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "DMTheme.js" as DMTheme

ComboBox {
    id: control

    property string themeName: ""
    property bool compact: false
    property string emptyText: ""
    property var textFormatter: null
    readonly property string dmThemeName: themeName.length > 0
                                          ? themeName
                                          : ((ApplicationWindow.window && ApplicationWindow.window.dmThemeName)
                                             ? ApplicationWindow.window.dmThemeName
                                             : "ocean")

    function formattedText(value, index) {
        return textFormatter ? textFormatter(value, index) : value
    }

    implicitHeight: compact ? 34 : 42
    leftPadding: compact ? 12 : 14
    rightPadding: compact ? 34 : 38
    topPadding: compact ? 6 : 9
    bottomPadding: compact ? 6 : 9

    font.pixelSize: compact ? 12 : 14
    font.family: Qt.platform.os === "ios" ? "Avenir Next" : "Noto Sans"

    opacity: control.enabled ? 1.0 : 0.58

    contentItem: Text {
        text: control.currentIndex >= 0
              ? control.formattedText(control.currentText, control.currentIndex)
              : control.emptyText
        color: DMTheme.fieldTextFor(control.dmThemeName, control.enabled)
        font: control.font
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    indicator: Rectangle {
        x: control.width - width - 4
        y: 4
        width: control.compact ? 24 : 28
        height: control.height - 8
        radius: 10
        border.width: 1
        border.color: DMTheme.spinIndicatorBorderFor(control.dmThemeName,
                                                     control.enabled,
                                                     control.popup.visible)
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: DMTheme.spinIndicatorTopFor(control.dmThemeName,
                                                   control.enabled,
                                                   control.popup.visible)
            }
            GradientStop {
                position: 1.0
                color: DMTheme.spinIndicatorBottomFor(control.dmThemeName,
                                                      control.enabled,
                                                      control.popup.visible)
            }
        }

        Text {
            anchors.centerIn: parent
            text: "v"
            color: DMTheme.colorFor(control.dmThemeName, "spinIndicatorText")
            font.pixelSize: control.compact ? 10 : 11
            font.bold: true
        }
    }

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

    delegate: ItemDelegate {
        required property int index

        width: ListView.view ? ListView.view.width : control.width
        text: control.formattedText(control.textAt(index), index)
        highlighted: control.highlightedIndex === index

        contentItem: Text {
            text: control.formattedText(control.textAt(index), index)
            color: highlighted ? DMTheme.colorFor(control.dmThemeName, "buttonText")
                               : DMTheme.colorFor(control.dmThemeName, "listRowText")
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            radius: 10
            border.width: 1
            border.color: highlighted
                          ? DMTheme.buttonBorderFor(control.dmThemeName, true, true, false, false)
                          : DMTheme.colorFor(control.dmThemeName, "listRowBorder")
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: highlighted
                           ? DMTheme.buttonTopFor(control.dmThemeName, true, true, false, false)
                           : DMTheme.colorFor(control.dmThemeName, "listRowTop")
                }
                GradientStop {
                    position: 1.0
                    color: highlighted
                           ? DMTheme.buttonBottomFor(control.dmThemeName, true, true, false, false)
                           : DMTheme.colorFor(control.dmThemeName, "listRowBottom")
                }
            }
            opacity: highlighted ? 1.0 : 0.82
        }
    }

    popup: Popup {
        y: control.height + 6
        width: control.width
        padding: 6

        implicitHeight: Math.min(contentItem.implicitHeight + topPadding + bottomPadding, 250)

        contentItem: ListView {
            clip: true
            spacing: 6
            implicitHeight: Math.min(contentHeight, 210)
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            radius: 14
            border.width: 1
            border.color: DMTheme.colorFor(control.dmThemeName, "cardBorder")
            gradient: Gradient {
                GradientStop { position: 0.0; color: DMTheme.colorFor(control.dmThemeName, "cardToneTop") }
                GradientStop { position: 1.0; color: DMTheme.colorFor(control.dmThemeName, "cardToneBottom") }
            }
        }
    }
}
