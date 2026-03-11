import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: page
    anchors.fill: parent
    property bool previewFullscreen: false
    property real previewFullscreenScale: 1.0
    property real previewPinchStartScale: 1.0

    ScrollView {
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.bottomMargin: 84
        clip: true

        ColumnLayout {
            width: page.width
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: statusCardContent.implicitHeight + 24
                radius: 14
                color: "#1a2533"
                border.color: "#34495d"

                ColumnLayout {
                    id: statusCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Label {
                        text: "Status: " + viewModel.statusText
                        font.bold: true
                        color: "#e3edf8"
                    }

                    Label {
                        visible: viewModel.lastError.length > 0
                        text: viewModel.lastError
                        color: "#ff7f90"
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
                color: "#1a2533"
                border.color: "#34495d"

                ColumnLayout {
                    id: promptCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Label {
                        text: "Prompt"
                        font.bold: true
                        color: "#e3edf8"
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
                        color: "#9bb1c8"
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
                color: "#1a2533"
                border.color: "#34495d"

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
                            color: "#e3edf8"
                        }

                        Item { Layout.fillWidth: true }

                        Label {
                            text: viewModel.inputImages.length + "/4"
                            color: "#9bb1c8"
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
                            color: "#1f2c3b"
                            border.color: "#395068"
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
                                    color: "#d6e3f3"
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
                color: "#1a2533"
                border.color: "#34495d"

                ColumnLayout {
                    id: settingsCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Label {
                        text: "Generation Settings"
                        font.bold: true
                        color: "#e3edf8"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Width"
                            color: "#9bb1c8"
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
                            color: "#9bb1c8"
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

                        Label { text: "Seed"; color: "#9bb1c8" }

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

                        Label { text: "Steps"; color: "#9bb1c8" }

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
                            color: "#9bb1c8"
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
                            color: "#d6e3f3"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Denoise"
                            color: "#9bb1c8"
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
                            color: "#d6e3f3"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label { text: "Sampler"; color: "#9bb1c8" }
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

                        Label { text: "Scheduler"; color: "#9bb1c8" }
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
                color: "#1a2533"
                border.color: "#34495d"

                ColumnLayout {
                    id: outputCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Label {
                        text: "Output + Server"
                        font.bold: true
                        color: "#e3edf8"
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
                        color: "#9bb1c8"
                        text: "Album source: " + viewModel.photoPickerDirUrl.toString()
                    }

                    Label {
                        visible: viewModel.mobilePlatform
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        color: "#9bb1c8"
                        text: "Save path: " + viewModel.picturesDirUrl.toString() + "/DreamMachine"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label { text: "Host"; color: "#9bb1c8" }
                        TextField {
                            Layout.fillWidth: true
                            enabled: !viewModel.running
                            text: viewModel.host
                            onTextChanged: viewModel.host = text
                        }

                        Label { text: "Port"; color: "#9bb1c8" }
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
                color: "#1a2533"
                border.color: "#34495d"

                ColumnLayout {
                    id: previewCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Label {
                        text: "Preview"
                        font.bold: true
                        color: "#e3edf8"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 260
                        radius: 10
                        color: "#121b26"
                        border.color: "#34495d"

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
                            color: "#8ea5bb"
                            visible: viewModel.previewImageUrl.length === 0
                        }

                        Label {
                            id: previewErrorLabel
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 8
                            color: "#ff7f90"
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

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.bottomMargin: 8
                implicitHeight: resultCardContent.implicitHeight + 24
                radius: 14
                color: "#1a2533"
                border.color: "#34495d"

                ColumnLayout {
                    id: resultCardContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Label {
                        text: "Result"
                        font.bold: true
                        color: "#e3edf8"
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

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.bottomMargin: 12
        implicitHeight: runBarContent.implicitHeight + 20
        radius: 14
        color: "#1a2533"
        border.color: "#34495d"

        RowLayout {
            id: runBarContent
            anchors.fill: parent
            anchors.margins: 10

            Button {
                Layout.fillWidth: true
                text: viewModel.running ? "Running" : "Run"
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
        fileMode: FileDialog.SaveFile
        defaultSuffix: "json"
        nameFilters: ["JSON (*.json)", "All files (*)"]
        onAccepted: viewModel.savePresetToUrl(selectedFile)
    }

    Rectangle {
        anchors.fill: parent
        visible: page.previewFullscreen
        z: 1000
        color: "#cc000000"

        onVisibleChanged: {
            if (visible) {
                page.previewFullscreenScale = 1.0
                page.previewPinchStartScale = 1.0
            }
        }

        Image {
            anchors.fill: parent
            anchors.margins: 16
            cache: false
            smooth: true
            fillMode: Image.PreserveAspectFit
            source: viewModel.previewImageUrl
            visible: viewModel.previewImageUrl.length > 0
            scale: page.previewFullscreenScale
        }

        PinchArea {
            anchors.fill: parent
            enabled: viewModel.previewImageUrl.length > 0

            onPinchStarted: {
                page.previewPinchStartScale = page.previewFullscreenScale
            }

            onPinchUpdated: {
                const scaled = page.previewPinchStartScale * pinch.scale
                page.previewFullscreenScale = Math.max(1.0, Math.min(4.0, scaled))
            }
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            color: "#e6eef8"
            text: "Pinch to zoom, tap image to exit fullscreen"
            visible: viewModel.previewImageUrl.length > 0
        }

        TapHandler {
            onTapped: page.previewFullscreen = false
        }
    }
}
