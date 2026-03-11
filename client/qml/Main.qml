import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

ApplicationWindow {
    id: shell
    width: 430
    height: 900
    visible: true
    title: "DreamMachine Mobile"

    property string currentMode: viewModel.mobilePlatform ? "simple" : "advanced"
    property string pendingMode: currentMode
    property bool switchingMode: false

    function requestMode(mode) {
        if (switchingMode || mode === currentMode) {
            modeDrawer.close()
            return
        }

        pendingMode = mode
        modeDrawer.close()
        modeSwitchAnimation.start()
    }

    Material.theme: Material.Dark
    Material.accent: Material.Teal
    Material.primary: Material.BlueGrey

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0f1520" }
            GradientStop { position: 1.0; color: "#111b28" }
        }
    }

    header: ToolBar {
        background: Rectangle {
            color: "#162231"
            border.color: "#2d4258"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 12
            spacing: 10

            ToolButton {
                id: menuButton
                text: "\u2630"
                font.pixelSize: 22
                leftPadding: 10
                rightPadding: 10
                topPadding: 6
                bottomPadding: 6
                enabled: !shell.switchingMode
                onClicked: modeDrawer.open()

                background: Rectangle {
                    radius: 12
                    color: menuButton.down ? "#35506a" : "#2a4054"
                    border.color: "#4a6278"
                }
            }

            Label {
                text: "DreamMachine"
                font.pixelSize: 19
                font.bold: true
                color: "#b7c7d9"
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                radius: 10
                color: viewModel.running ? "#1f4e3c" : "#253445"
                border.color: viewModel.running ? "#3f8163" : "#45607a"
                implicitHeight: 30
                implicitWidth: statusText.implicitWidth + 18

                Label {
                    id: statusText
                    anchors.centerIn: parent
                    text: viewModel.running ? "Running" : "Ready"
                    font.pixelSize: 13
                    color: "#d4e1ef"
                }
            }
        }
    }

    Drawer {
        id: modeDrawer
        edge: Qt.LeftEdge
        width: Math.min(shell.width * 0.74, 290)
        height: shell.height
        modal: true

        background: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#111c2b" }
                GradientStop { position: 1.0; color: "#0f1724" }
            }
            border.color: "#2e4358"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                radius: 12
                color: "#1b2938"
                border.color: "#334b62"
                implicitHeight: 72

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 3

                    Label {
                        text: "Interface Mode"
                        font.bold: true
                        color: "#e3edf8"
                    }

                    Label {
                        text: "Choose Simple or Advanced"
                        color: "#9bb1c8"
                        font.pixelSize: 12
                    }
                }
            }

            ItemDelegate {
                Layout.fillWidth: true
                text: shell.currentMode === "simple" ? "Simple (Current)" : "Simple"
                highlighted: shell.currentMode === "simple"
                enabled: !shell.switchingMode
                onClicked: shell.requestMode("simple")
            }

            ItemDelegate {
                Layout.fillWidth: true
                text: shell.currentMode === "advanced" ? "Advanced (Current)" : "Advanced"
                highlighted: shell.currentMode === "advanced"
                enabled: !shell.switchingMode
                onClicked: shell.requestMode("advanced")
            }
        }
    }

    Item {
        id: pageHost
        anchors.fill: parent
        opacity: 1.0
        scale: 1.0
        enabled: !shell.switchingMode

        Loader {
            anchors.fill: parent
            source: shell.currentMode === "simple"
                    ? "qrc:/qml/SimplePage.qml"
                    : "qrc:/qml/AdvancedPage.qml"
        }
    }

    SequentialAnimation {
        id: modeSwitchAnimation

        ScriptAction {
            script: shell.switchingMode = true
        }

        ParallelAnimation {
            NumberAnimation {
                target: pageHost
                property: "opacity"
                to: 0.0
                duration: 130
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: pageHost
                property: "scale"
                to: 0.985
                duration: 130
                easing.type: Easing.OutCubic
            }
        }

        ScriptAction {
            script: shell.currentMode = shell.pendingMode
        }

        ParallelAnimation {
            NumberAnimation {
                target: pageHost
                property: "opacity"
                to: 1.0
                duration: 190
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: pageHost
                property: "scale"
                to: 1.0
                duration: 190
                easing.type: Easing.OutCubic
            }
        }

        ScriptAction {
            script: shell.switchingMode = false
        }
    }
}
