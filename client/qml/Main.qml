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

    Material.theme: Material.Light
    Material.accent: Material.Teal
    Material.primary: Material.BlueGrey

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#f4f8fb" }
            GradientStop { position: 1.0; color: "#eef5f1" }
        }
    }

    header: ToolBar {
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
                    color: menuButton.down ? "#d5e8f7" : "#eaf3fb"
                    border.color: "#c9ddec"
                }
            }

            Label {
                text: shell.currentMode === "simple" ? "DreamMachine Simple" : "DreamMachine Advanced"
                font.pixelSize: 19
                font.bold: true
                color: "#17354a"
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                radius: 10
                color: viewModel.running ? "#d8f2e2" : "#e9eef3"
                border.color: viewModel.running ? "#9bd0ae" : "#cfdbe6"
                implicitHeight: 30
                implicitWidth: statusText.implicitWidth + 18

                Label {
                    id: statusText
                    anchors.centerIn: parent
                    text: viewModel.running ? "Running" : "Ready"
                    font.pixelSize: 13
                    color: "#2f4f63"
                }
            }

            Button {
                visible: shell.currentMode === "advanced"
                text: viewModel.running ? "Running" : "Run"
                enabled: !viewModel.running && !shell.switchingMode
                onClicked: viewModel.runInference()
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
                GradientStop { position: 0.0; color: "#f9fcff" }
                GradientStop { position: 1.0; color: "#f2f8fd" }
            }
            border.color: "#d4e2ee"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                radius: 12
                color: "#ffffff"
                border.color: "#d7e4ef"
                implicitHeight: 72

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 3

                    Label {
                        text: "Interface Mode"
                        font.bold: true
                        color: "#1f3a4a"
                    }

                    Label {
                        text: "Choose Simple or Advanced"
                        color: "#4a6478"
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
