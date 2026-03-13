import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window
import "components"
import "components/DMTheme.js" as DMTheme

Item {
    id: page
    anchors.fill: parent
    property bool previewFullscreen: false
    readonly property string dmThemeName: (ApplicationWindow.window && ApplicationWindow.window.dmThemeName)
                                          ? ApplicationWindow.window.dmThemeName
                                          : "ocean"
    readonly property color textPrimary: DMTheme.colorFor(dmThemeName, "textPrimary")
    readonly property color textSecondary: DMTheme.colorFor(dmThemeName, "textSecondary")
    readonly property color textError: DMTheme.colorFor(dmThemeName, "textError")
    readonly property color listRowBorder: DMTheme.colorFor(dmThemeName, "listRowBorder")
    readonly property color listRowTop: DMTheme.colorFor(dmThemeName, "listRowTop")
    readonly property color listRowBottom: DMTheme.colorFor(dmThemeName, "listRowBottom")
    readonly property color listRowText: DMTheme.colorFor(dmThemeName, "listRowText")

    DMPreviewChrome {
        id: previewChrome
        themeName: page.dmThemeName
    }

    ScrollView {
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.bottomMargin: 84
        clip: true

        ColumnLayout {
            width: page.width
            spacing: 12

            DMCard {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: statusCardContent.implicitHeight + 24
                radius: 18

                ColumnLayout {
                    id: statusCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Label {
                        text: "Status: " + viewModel.statusText
                        font.bold: true
                        color: page.textPrimary
                    }

                    Label {
                        visible: viewModel.lastError.length > 0
                        text: viewModel.lastError
                        color: page.textError
                        wrapMode: Text.Wrap
                    }
                }
            }

            DMCard {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: promptCardContent.implicitHeight + 24
                radius: 18

                ColumnLayout {
                    id: promptCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Label {
                        text: "Prompt"
                        font.bold: true
                        color: page.textPrimary
                    }

                    DMTextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        placeholderText: "Describe what you want to generate"
                        wrapMode: TextArea.Wrap
                        text: viewModel.prompt
                        onTextChanged: viewModel.prompt = text
                    }

                    Label {
                        text: "Negative Prompt"
                        color: page.textSecondary
                    }

                    DMTextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        placeholderText: "Optional"
                        wrapMode: TextArea.Wrap
                        text: viewModel.negPrompt
                        onTextChanged: viewModel.negPrompt = text
                    }
                }
            }

            DMCard {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: inputCardContent.implicitHeight + 24
                radius: 18

                ColumnLayout {
                    id: inputCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "Input Images"
                            font.bold: true
                            color: page.textPrimary
                        }

                        Item { Layout.fillWidth: true }

                        Label {
                            text: viewModel.inputImages.length + "/4"
                            color: page.textSecondary
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        DMButton {
                            Layout.fillWidth: true
                            text: viewModel.mobilePlatform ? "Add From Album" : "Add"
                            primary: true
                            enabled: !viewModel.running && viewModel.inputImages.length < 4
                            onClicked: inputImageDialog.open()
                        }

                        DMButton {
                            Layout.fillWidth: true
                            text: "Clear"
                            danger: true
                            enabled: !viewModel.running && viewModel.inputImages.length > 0
                            onClicked: viewModel.clearInputImages()
                        }
                    }

                    Repeater {
                        model: viewModel.inputImages

                        delegate: Rectangle {
                            required property string modelData
                            required property int index

                            Layout.fillWidth: true
                            radius: 12
                            border.color: page.listRowBorder
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: page.listRowTop }
                                GradientStop { position: 1.0; color: page.listRowBottom }
                            }
                            implicitHeight: row.implicitHeight + 10

                            RowLayout {
                                id: row
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 8

                                Label {
                                    Layout.fillWidth: true
                                    text: modelData
                                    elide: Text.ElideMiddle
                                    color: page.listRowText
                                }

                                DMButton {
                                    compact: true
                                    text: "Remove"
                                    danger: true
                                    enabled: !viewModel.running
                                    onClicked: viewModel.removeInputImage(index)
                                }
                            }
                        }
                    }
                }
            }

            DMCard {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: settingsCardContent.implicitHeight + 24
                radius: 18

                ColumnLayout {
                    id: settingsCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Label {
                        text: "Generation Settings"
                        font.bold: true
                        color: page.textPrimary
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Width"
                            color: page.textSecondary
                        }

                        DMSpinBox {
                            from: 0
                            to: 16384
                            editable: true
                            value: viewModel.targetWidth
                            enabled: !viewModel.hasInputImages && !viewModel.running
                            onValueChanged: viewModel.targetWidth = value
                        }

                        Label {
                            text: "Height"
                            color: page.textSecondary
                        }

                        DMSpinBox {
                            from: 0
                            to: 16384
                            editable: true
                            value: viewModel.targetHeight
                            enabled: !viewModel.hasInputImages && !viewModel.running
                            onValueChanged: viewModel.targetHeight = value
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label { text: "Seed"; color: page.textSecondary }

                        DMTextField {
                            Layout.fillWidth: true
                            enabled: !viewModel.running
                            text: viewModel.seedText
                            placeholderText: "Integer, use -1 for random"
                            inputMethodHints: Qt.ImhPreferNumbers
                            onTextChanged: viewModel.seedText = text
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label { text: "Steps"; color: page.textSecondary }

                        DMSpinBox {
                            from: 1
                            to: 500
                            editable: true
                            value: viewModel.steps
                            enabled: !viewModel.running
                            onValueChanged: viewModel.steps = value
                        }

                        Label {
                            text: "CFG"
                            color: page.textSecondary
                        }

                        DMSlider {
                            Layout.fillWidth: true
                            from: 0.0
                            to: 100.0
                            stepSize: 0.1
                            value: viewModel.cfg
                            enabled: !viewModel.running
                            onMoved: viewModel.cfg = value
                            onValueChanged: if (pressed) viewModel.cfg = value
                        }

                        DMTextField {
                            id: cfgInput
                            Layout.preferredWidth: 76
                            enabled: !viewModel.running
                            horizontalAlignment: Text.AlignHCenter
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: DoubleValidator {
                                bottom: 0.0
                                top: 100.0
                                decimals: 1
                                notation: DoubleValidator.StandardNotation
                            }

                            Binding {
                                target: cfgInput
                                property: "text"
                                value: Number(viewModel.cfg).toFixed(1)
                                when: !cfgInput.activeFocus
                            }

                            onEditingFinished: {
                                let parsed = Number(text)
                                if (!isFinite(parsed)) {
                                    text = Number(viewModel.cfg).toFixed(1)
                                    return
                                }

                                parsed = Math.max(0.0, Math.min(100.0, parsed))
                                parsed = Math.round(parsed * 10) / 10
                                viewModel.cfg = parsed
                                text = Number(parsed).toFixed(1)
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Denoise"
                            color: page.textSecondary
                        }

                        DMSlider {
                            Layout.fillWidth: true
                            from: 0.0
                            to: 1.0
                            stepSize: 0.01
                            value: viewModel.denoise
                            enabled: !viewModel.running
                            onMoved: viewModel.denoise = value
                            onValueChanged: if (pressed) viewModel.denoise = value
                        }

                        DMTextField {
                            id: denoiseInput
                            Layout.preferredWidth: 76
                            enabled: !viewModel.running
                            horizontalAlignment: Text.AlignHCenter
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: DoubleValidator {
                                bottom: 0.0
                                top: 1.0
                                decimals: 2
                                notation: DoubleValidator.StandardNotation
                            }

                            Binding {
                                target: denoiseInput
                                property: "text"
                                value: Number(viewModel.denoise).toFixed(2)
                                when: !denoiseInput.activeFocus
                            }

                            onEditingFinished: {
                                let parsed = Number(text)
                                if (!isFinite(parsed)) {
                                    text = Number(viewModel.denoise).toFixed(2)
                                    return
                                }

                                parsed = Math.max(0.0, Math.min(1.0, parsed))
                                parsed = Math.round(parsed * 100) / 100
                                viewModel.denoise = parsed
                                text = Number(parsed).toFixed(2)
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label { text: "Sampler"; color: page.textSecondary }
                        DMTextField {
                            Layout.fillWidth: true
                            enabled: !viewModel.running
                            text: viewModel.samplerName
                            onTextChanged: viewModel.samplerName = text
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label { text: "Scheduler"; color: page.textSecondary }
                        DMTextField {
                            Layout.fillWidth: true
                            enabled: !viewModel.running
                            text: viewModel.scheduler
                            onTextChanged: viewModel.scheduler = text
                        }
                    }
                }
            }

            DMCard {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: outputCardContent.implicitHeight + 24
                radius: 18

                ColumnLayout {
                    id: outputCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Label {
                        text: "Output + Server"
                        font.bold: true
                        color: page.textPrimary
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        visible: !viewModel.mobilePlatform

                        DMTextField {
                            Layout.fillWidth: true
                            text: viewModel.outputDir
                            placeholderText: "Output directory"
                            enabled: !viewModel.running
                            onTextChanged: viewModel.outputDir = text
                        }

                        DMButton {
                            compact: true
                            text: "Dir"
                            enabled: !viewModel.running
                            onClicked: outputFolderDialog.open()
                        }
                    }

                    Label {
                        visible: viewModel.mobilePlatform
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        color: page.textSecondary
                        text: "Album source: " + viewModel.photoPickerDirUrl.toString()
                    }

                    Label {
                        visible: viewModel.mobilePlatform
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        color: page.textSecondary
                        text: "Save path: " + viewModel.picturesDirUrl.toString() + "/DreamMachine"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label { text: "Host"; color: page.textSecondary }
                        DMTextField {
                            Layout.fillWidth: true
                            enabled: !viewModel.running
                            text: viewModel.host
                            onTextChanged: viewModel.host = text
                        }

                        Label { text: "Port"; color: page.textSecondary }
                        DMSpinBox {
                            from: 1
                            to: 65535
                            editable: true
                            value: viewModel.port
                            enabled: !viewModel.running
                            onValueChanged: viewModel.port = value
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        DMButton {
                            Layout.fillWidth: true
                            text: "Load Preset"
                            enabled: !viewModel.running
                            onClicked: presetLoadDialog.open()
                        }

                        DMButton {
                            Layout.fillWidth: true
                            text: "Save Preset"
                            enabled: !viewModel.running
                            onClicked: presetSaveDialog.open()
                        }

                        DMButton {
                            Layout.fillWidth: true
                            primary: true
                            text: viewModel.mobilePlatform ? "Save To Album" : "Save Image"
                            enabled: viewModel.canSaveImage
                            onClicked: {
                                if (viewModel.mobilePlatform) {
                                    viewModel.saveGeneratedImageToAlbum()
                                } else {
                                    viewModel.saveGeneratedImage()
                                }
                            }
                        }
                    }
                }
            }

            DMCard {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: previewCardContent.implicitHeight + 24
                radius: 18

                ColumnLayout {
                    id: previewCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Label {
                        text: "Preview"
                        font.bold: true
                        color: page.textPrimary
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 260
                        radius: 14
                        border.color: previewChrome.surfaceBorder
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: previewChrome.surfaceTop }
                            GradientStop { position: 1.0; color: previewChrome.surfaceBottom }
                        }

                        Image {
                            id: previewImage
                            anchors.fill: parent
                            anchors.margins: 8
                            cache: false
                            fillMode: Image.PreserveAspectFit
                            source: viewModel.previewImageUrl
                            visible: viewModel.previewImageUrl.length > 0

                            onStatusChanged: {
                                if (status === Image.Error) {
                                    previewErrorLabel.text = "Preview load failed: " + source
                                } else if (status === Image.Ready) {
                                    previewErrorLabel.text = ""
                                }
                            }
                        }

                        Label {
                            anchors.centerIn: parent
                            text: "No preview yet"
                            color: previewChrome.hintText
                            visible: viewModel.previewImageUrl.length === 0
                        }

                        Label {
                            id: previewErrorLabel
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 8
                            color: previewChrome.errorText
                            wrapMode: Text.Wrap
                            visible: text.length > 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: viewModel.previewImageUrl.length > 0
                            onClicked: page.previewFullscreen = true
                        }
                    }
                }
            }

            DMCard {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.bottomMargin: 8
                implicitHeight: resultCardContent.implicitHeight + 24
                radius: 18

                ColumnLayout {
                    id: resultCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Label {
                        text: "Result"
                        font.bold: true
                        color: page.textPrimary
                    }

                    DMTextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 240
                        readOnly: true
                        wrapMode: TextArea.WrapAnywhere
                        text: viewModel.resultText
                    }
                }
            }
        }
    }

    DMCard {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.bottomMargin: 12
        implicitHeight: runBarContent.implicitHeight + 20
        radius: 18

        RowLayout {
            id: runBarContent
            anchors.fill: parent
            anchors.margins: 10

            DMButton {
                Layout.fillWidth: true
                text: viewModel.running ? "Running" : "Run"
                primary: true
                enabled: !viewModel.running
                onClicked: viewModel.runInference()
            }
        }
    }

    FileDialog {
        id: inputImageDialog
        title: viewModel.mobilePlatform ? "Select photos" : "Select input images"
        fileMode: FileDialog.OpenFiles
        currentFolder: viewModel.mobilePlatform ? viewModel.photoPickerDirUrl : viewModel.outputDirUrl
        nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.bmp)", "All files (*)"]
        onAccepted: {
            for (let i = 0; i < selectedFiles.length; ++i) {
                viewModel.addInputImageUrl(selectedFiles[i])
            }
        }
    }

    FolderDialog {
        id: outputFolderDialog
        title: "Choose output directory"
        currentFolder: viewModel.outputDirUrl
        onAccepted: viewModel.setOutputDirFromUrl(selectedFolder)
    }

    FileDialog {
        id: presetLoadDialog
        title: "Load preset"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Preset files (*.json *.png)", "All files (*)"]
        onAccepted: viewModel.loadPresetFromUrl(selectedFile)
    }

    FileDialog {
        id: presetSaveDialog
        title: "Save preset"
        // iOS SaveFile falls back to the Qt dialog; OpenFile keeps the native picker.
        fileMode: Qt.platform.os === "ios" ? FileDialog.OpenFile : FileDialog.SaveFile
        defaultSuffix: "json"
        nameFilters: ["JSON (*.json)", "All files (*)"]
        onAccepted: viewModel.savePresetToUrl(selectedFile)
    }

    DMFullscreenImageViewer {
        anchors.fill: parent
        active: page.previewFullscreen
        imageUrl: viewModel.previewImageUrl
        overlayColor: previewChrome.fullscreenOverlay
        hintColor: previewChrome.fullscreenHint
        onCloseRequested: page.previewFullscreen = false
    }
}
