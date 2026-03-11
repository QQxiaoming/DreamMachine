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
    property string dmThemeName: "rose"
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

    DMMainChrome {
        id: mainChrome
        anchors.fill: parent
        themeName: shell.dmThemeName
    }

    header: ToolBar {
        background: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: mainChrome.headerTop }
                GradientStop { position: 1.0; color: mainChrome.headerBottom }
            }
            border.color: mainChrome.headerBorder
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
                    border.color: menuButton.down ? mainChrome.menuButtonBorderDown : mainChrome.menuButtonBorder
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: menuButton.down ? mainChrome.menuButtonTopDown : mainChrome.menuButtonTop
                        }
                        GradientStop {
                            position: 1.0
                            color: menuButton.down ? mainChrome.menuButtonBottomDown : mainChrome.menuButtonBottom
                        }
                    }
                }
            }

            Label {
                text: "DreamMachine"
                font.pixelSize: 19
                font.bold: true
                color: mainChrome.titleText
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                radius: 10
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: viewModel.running ? mainChrome.statusRunningTop : mainChrome.statusIdleTop
                    }
                    GradientStop {
                        position: 1.0
                        color: viewModel.running ? mainChrome.statusRunningBottom : mainChrome.statusIdleBottom
                    }
                }
                border.color: viewModel.running ? mainChrome.statusRunningBorder : mainChrome.statusIdleBorder
                implicitHeight: 30
                implicitWidth: statusText.implicitWidth + 18

                Label {
                    id: statusText
                    anchors.centerIn: parent
                    text: viewModel.running ? "Running" : "Ready"
                    font.pixelSize: 13
                    color: mainChrome.statusText
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
            color: mainChrome.drawerOverlay
        }

        background: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: mainChrome.drawerTop }
                GradientStop { position: 1.0; color: mainChrome.drawerBottom }
            }
            border.color: mainChrome.drawerBorder
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
                        color: mainChrome.drawerTitleText
                    }

                    Label {
                        text: "Choose Simple or Advanced"
                        color: mainChrome.drawerSubtitleText
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

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "Theme"
                            font.bold: true
                            color: mainChrome.drawerTitleText
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Label {
                            text: shell.availableThemes.length + " themes"
                            font.pixelSize: 11
                            color: mainChrome.drawerSubtitleText
                        }
                    }

                    DMComboBox {
                        id: themeSelector
                        Layout.fillWidth: true
                        enabled: !shell.switchingMode && shell.availableThemes.length > 0
                        emptyText: "No themes"
                        model: shell.availableThemes
                        currentIndex: {
                            var idx = shell.availableThemes.indexOf(shell.dmThemeName)
                            return idx >= 0 ? idx : (shell.availableThemes.length > 0 ? 0 : -1)
                        }
                        textFormatter: function(value) {
                            return shell.themeDisplayName(value)
                        }

                        onCurrentIndexChanged: {
                            if (currentIndex >= 0 && currentIndex < shell.availableThemes.length) {
                                var selectedTheme = shell.availableThemes[currentIndex]
                                if (shell.dmThemeName !== selectedTheme) {
                                    shell.dmThemeName = selectedTheme
                                }
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
