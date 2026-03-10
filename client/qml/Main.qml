import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: window
    width: 430
    height: 900
    visible: true
    title: "DreamMachine Mobile"
    property bool previewFullscreen: false
    property real previewFullscreenScale: 1.0
    property real previewPinchStartScale: 1.0

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
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            Label {
                text: "DreamMachine"
                font.pixelSize: 20
                font.bold: true
                color: "#17354a"
            }

            Item { Layout.fillWidth: true }

            Button {
                text: viewModel.running ? "Running" : "Run"
                enabled: !viewModel.running
                onClicked: viewModel.runInference()
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.topMargin: 8
        clip: true

        ColumnLayout {
            width: window.width
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: statusCardContent.implicitHeight + 24
                radius: 14
                color: "#ffffff"
                border.color: "#dce7ee"

                ColumnLayout {
                    id: statusCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Label {
                        text: "Status: " + viewModel.statusText
                        font.bold: true
                        color: "#1f3a4a"
                    }

                    Label {
                        visible: viewModel.lastError.length > 0
                        text: viewModel.lastError
                        color: "#b00020"
                        wrapMode: Text.Wrap
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: promptCardContent.implicitHeight + 24
                radius: 14
                color: "#ffffff"
                border.color: "#dce7ee"

                ColumnLayout {
                    id: promptCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Label {
                        text: "Prompt"
                        font.bold: true
                        color: "#1f3a4a"
                    }

                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        placeholderText: "Describe what you want to generate"
                        wrapMode: TextArea.Wrap
                        text: viewModel.prompt
                        onTextChanged: viewModel.prompt = text
                    }

                    Label {
                        text: "Negative Prompt"
                        color: "#4a6478"
                    }

                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        placeholderText: "Optional"
                        wrapMode: TextArea.Wrap
                        text: viewModel.negPrompt
                        onTextChanged: viewModel.negPrompt = text
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: inputCardContent.implicitHeight + 24
                radius: 14
                color: "#ffffff"
                border.color: "#dce7ee"

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
                            color: "#1f3a4a"
                        }

                        Item { Layout.fillWidth: true }

                        Label {
                            text: viewModel.inputImages.length + "/4"
                            color: "#4a6478"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Button {
                            text: viewModel.mobilePlatform ? "Add From Album" : "Add"
                            enabled: !viewModel.running && viewModel.inputImages.length < 4
                            onClicked: inputImageDialog.open()
                        }

                        Button {
                            text: "Clear"
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
                            radius: 10
                            color: "#f7fbff"
                            border.color: "#d9e7f2"
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
                                    color: "#2c3e50"
                                }

                                ToolButton {
                                    text: "Remove"
                                    enabled: !viewModel.running
                                    onClicked: viewModel.removeInputImage(index)
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: settingsCardContent.implicitHeight + 24
                radius: 14
                color: "#ffffff"
                border.color: "#dce7ee"

                ColumnLayout {
                    id: settingsCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Label {
                        text: "Generation Settings"
                        font.bold: true
                        color: "#1f3a4a"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Width"
                            color: "#4a6478"
                        }

                        SpinBox {
                            from: 0
                            to: 16384
                            editable: true
                            value: viewModel.targetWidth
                            enabled: !viewModel.hasInputImages && !viewModel.running
                            onValueChanged: viewModel.targetWidth = value
                        }

                        Label {
                            text: "Height"
                            color: "#4a6478"
                        }

                        SpinBox {
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

                        Label { text: "Seed"; color: "#4a6478" }

                        TextField {
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

                        Label { text: "Steps"; color: "#4a6478" }

                        SpinBox {
                            from: 1
                            to: 500
                            editable: true
                            value: viewModel.steps
                            enabled: !viewModel.running
                            onValueChanged: viewModel.steps = value
                        }

                        Label {
                            text: "CFG"
                            color: "#4a6478"
                        }

                        Slider {
                            Layout.fillWidth: true
                            from: 0.0
                            to: 100.0
                            stepSize: 0.1
                            value: viewModel.cfg
                            enabled: !viewModel.running
                            onMoved: viewModel.cfg = value
                            onValueChanged: if (pressed) viewModel.cfg = value
                        }

                        Label {
                            text: Number(viewModel.cfg).toFixed(1)
                            color: "#2c3e50"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Denoise"
                            color: "#4a6478"
                        }

                        Slider {
                            Layout.fillWidth: true
                            from: 0.0
                            to: 1.0
                            stepSize: 0.01
                            value: viewModel.denoise
                            enabled: !viewModel.running
                            onMoved: viewModel.denoise = value
                            onValueChanged: if (pressed) viewModel.denoise = value
                        }

                        Label {
                            text: Number(viewModel.denoise).toFixed(2)
                            color: "#2c3e50"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label { text: "Sampler"; color: "#4a6478" }
                        TextField {
                            Layout.fillWidth: true
                            enabled: !viewModel.running
                            text: viewModel.samplerName
                            onTextChanged: viewModel.samplerName = text
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label { text: "Scheduler"; color: "#4a6478" }
                        TextField {
                            Layout.fillWidth: true
                            enabled: !viewModel.running
                            text: viewModel.scheduler
                            onTextChanged: viewModel.scheduler = text
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: outputCardContent.implicitHeight + 24
                radius: 14
                color: "#ffffff"
                border.color: "#dce7ee"

                ColumnLayout {
                    id: outputCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Label {
                        text: "Output + Server"
                        font.bold: true
                        color: "#1f3a4a"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        visible: !viewModel.mobilePlatform

                        TextField {
                            Layout.fillWidth: true
                            text: viewModel.outputDir
                            placeholderText: "Output directory"
                            enabled: !viewModel.running
                            onTextChanged: viewModel.outputDir = text
                        }

                        Button {
                            text: "Dir"
                            enabled: !viewModel.running
                            onClicked: outputFolderDialog.open()
                        }
                    }

                    Label {
                        visible: viewModel.mobilePlatform
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        color: "#4a6478"
                        text: "Album source: " + viewModel.photoPickerDirUrl.toString()
                    }

                    Label {
                        visible: viewModel.mobilePlatform
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        color: "#4a6478"
                        text: "Save path: " + viewModel.picturesDirUrl.toString() + "/DreamMachine"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label { text: "Host"; color: "#4a6478" }
                        TextField {
                            Layout.fillWidth: true
                            enabled: !viewModel.running
                            text: viewModel.host
                            onTextChanged: viewModel.host = text
                        }

                        Label { text: "Port"; color: "#4a6478" }
                        SpinBox {
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

                        Button {
                            text: "Load Preset"
                            enabled: !viewModel.running
                            onClicked: presetLoadDialog.open()
                        }

                        Button {
                            text: "Save Preset"
                            enabled: !viewModel.running
                            onClicked: presetSaveDialog.open()
                        }

                        Button {
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

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: previewCardContent.implicitHeight + 24
                radius: 14
                color: "#ffffff"
                border.color: "#dce7ee"

                ColumnLayout {
                    id: previewCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Label {
                        text: "Preview"
                        font.bold: true
                        color: "#1f3a4a"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 260
                        radius: 10
                        color: "#f8fbfd"
                        border.color: "#dce7ee"

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
                            color: "#6a8294"
                            visible: viewModel.previewImageUrl.length === 0
                        }

                        Label {
                            id: previewErrorLabel
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 8
                            color: "#b00020"
                            wrapMode: Text.Wrap
                            visible: text.length > 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: viewModel.previewImageUrl.length > 0
                            onClicked: window.previewFullscreen = true
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.bottomMargin: 24
                implicitHeight: resultCardContent.implicitHeight + 24
                radius: 14
                color: "#ffffff"
                border.color: "#dce7ee"

                ColumnLayout {
                    id: resultCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Label {
                        text: "Result"
                        font.bold: true
                        color: "#1f3a4a"
                    }

                    TextArea {
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
        fileMode: FileDialog.SaveFile
        defaultSuffix: "json"
        nameFilters: ["JSON (*.json)", "All files (*)"]
        onAccepted: viewModel.savePresetToUrl(selectedFile)
    }

    Rectangle {
        anchors.fill: parent
        visible: window.previewFullscreen
        z: 1000
        color: "#e6000000"

        onVisibleChanged: {
            if (visible) {
                window.previewFullscreenScale = 1.0
                window.previewPinchStartScale = 1.0
            }
        }

        Image {
            id: fullscreenPreviewImage
            anchors.fill: parent
            anchors.margins: 16
            cache: false
            smooth: true
            fillMode: Image.PreserveAspectFit
            source: viewModel.previewImageUrl
            visible: viewModel.previewImageUrl.length > 0
            scale: window.previewFullscreenScale
        }

        PinchArea {
            anchors.fill: parent
            enabled: viewModel.previewImageUrl.length > 0

            onPinchStarted: {
                window.previewPinchStartScale = window.previewFullscreenScale
            }

            onPinchUpdated: {
                const scaled = window.previewPinchStartScale * pinch.scale
                window.previewFullscreenScale = Math.max(1.0, Math.min(4.0, scaled))
            }
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            color: "#ffffff"
            text: "Pinch to zoom, tap image to exit fullscreen"
            visible: viewModel.previewImageUrl.length > 0
        }

        TapHandler {
            onTapped: window.previewFullscreen = false
        }
    }
}
