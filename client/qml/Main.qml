import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "components"
import "components/DMTheme.js" as DMTheme

ApplicationWindow {
    id: shell
    width: 430
    height: 900
    visible: true
    title: "DreamMachine Mobile"
    font.family: Qt.platform.os === "ios" ? "Avenir Next" : "Noto Sans"
    font.pixelSize: 14

    property string currentMode: viewModel.mobilePlatform ? "simple" : "advanced"
    property string pendingMode: currentMode
    property bool switchingMode: false
    property string dmThemeName: "ocean"
    property var availableThemes: DMTheme.themeNames()

    onDmThemeNameChanged: DMTheme.setTheme(dmThemeName)

    Component.onCompleted: {
        DMTheme.setTheme(dmThemeName)
    }

    function requestMode(mode) {
        if (switchingMode || mode === currentMode) {
            modeDrawer.close()
            return
        }

        pendingMode = mode
        modeDrawer.close()
        modeSwitchAnimation.start()
    }

    function themeDisplayName(name) {
        if (!name || name.length === 0) {
            return ""
        }

        return name.charAt(0).toUpperCase() + name.slice(1)
    }

    Material.theme: Material.Dark
    Material.accent: Material.Teal
    Material.primary: Material.BlueGrey

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0d1724" }
            GradientStop { position: 0.48; color: "#101f2f" }
            GradientStop { position: 1.0; color: "#11273c" }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            width: parent.width * 0.55
            height: parent.height * 0.36
            radius: width * 0.5
            color: "#1d455f"
            opacity: 0.2
            transform: Rotation {
                origin.x: width * 0.5
                origin.y: height * 0.5
                angle: -18
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: parent.width * 0.6
            height: parent.height * 0.26
            radius: width * 0.5
            color: "#0f7f67"
            opacity: 0.12
        }
    }

    header: ToolBar {
        background: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#192e41" }
                GradientStop { position: 1.0; color: "#132334" }
            }
            border.color: "#365470"
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
                    border.color: menuButton.down ? "#7ec2ea" : "#5f89ab"
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: menuButton.down ? "#2f5f80" : "#3b6d90"
                        }
                        GradientStop {
                            position: 1.0
                            color: menuButton.down ? "#244c69" : "#2d5b7a"
                        }
                    }
                }
            }

            Label {
                text: "DreamMachine"
                font.pixelSize: 19
                font.bold: true
                color: "#d8e8f8"
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                radius: 10
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: viewModel.running ? "#1f6650" : "#2b4b67"
                    }
                    GradientStop {
                        position: 1.0
                        color: viewModel.running ? "#165241" : "#233d54"
                    }
                }
                border.color: viewModel.running ? "#66d3aa" : "#6ba7d1"
                implicitHeight: 30
                implicitWidth: statusText.implicitWidth + 18

                Label {
                    id: statusText
                    anchors.centerIn: parent
                    text: viewModel.running ? "Running" : "Ready"
                    font.pixelSize: 13
                    color: "#edf5ff"
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
        Overlay.modal: Rectangle {
            color: "#b3000000"
        }

        background: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#13263a" }
                GradientStop { position: 1.0; color: "#0f1d2c" }
            }
            border.color: "#3e617f"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            DMCard {
                Layout.fillWidth: true
                radius: 14
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
                        color: "#b4cade"
                        font.pixelSize: 12
                    }
                }
            }

            DMButton {
                Layout.fillWidth: true
                text: "Simple"
                primary: shell.currentMode === "simple"
                enabled: !shell.switchingMode
                onClicked: shell.requestMode("simple")
            }

            DMButton {
                Layout.fillWidth: true
                text: "Advanced"
                primary: shell.currentMode === "advanced"
                enabled: !shell.switchingMode
                onClicked: shell.requestMode("advanced")
            }

            Item {
                Layout.fillHeight: true
            }

            DMCard {
                Layout.fillWidth: true
                implicitHeight: themePanel.implicitHeight + 20

                ColumnLayout {
                    id: themePanel
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Label {
                        text: "Theme"
                        font.bold: true
                        color: "#e3edf8"
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 8
                        rowSpacing: 8

                        Repeater {
                            model: shell.availableThemes

                            delegate: DMButton {
                                required property string modelData
                                Layout.fillWidth: true
                                compact: true
                                text: shell.themeDisplayName(modelData)
                                primary: shell.dmThemeName === modelData
                                enabled: !shell.switchingMode
                                onClicked: shell.dmThemeName = modelData
                            }
                        }
                    }
                }
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
