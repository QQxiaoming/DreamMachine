import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: page
    anchors.fill: parent

    property string displayImageUrl: ""
    property bool waitingResult: false
    property bool previewFullscreen: false
    property real previewFullscreenScale: 1.0
    property real previewPinchStartScale: 1.0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        anchors.topMargin: 20
        spacing: 12

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: statusContent.implicitHeight + 20
            radius: 14
            color: "#ffffff"
            border.color: "#dce7ee"

            ColumnLayout {
                id: statusContent
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6

                Label {
                    text: "Status: " + viewModel.statusText
                    font.bold: true
                    color: "#1f3a4a"
                }

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    color: "#4a6478"
                    text: "Select one input image. The app will automatically run using your current Advanced mode parameters, then replace this preview with the generated output."
                }

                Label {
                    visible: viewModel.lastError.length > 0
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    color: "#b00020"
                    text: viewModel.lastError
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
            color: "#ffffff"
            border.color: "#dce7ee"

            Rectangle {
                anchors.fill: parent
                anchors.margins: 10
                radius: 10
                color: "#f8fbfd"
                border.color: "#dce7ee"

                Image {
                    anchors.fill: parent
                    anchors.margins: 8
                    cache: false
                    smooth: true
                    fillMode: Image.PreserveAspectFit
                    source: page.displayImageUrl
                    visible: page.displayImageUrl.length > 0

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
                    text: "No image selected"
                    color: "#6a8294"
                    visible: page.displayImageUrl.length === 0
                }

                BusyIndicator {
                    anchors.centerIn: parent
                    running: viewModel.running
                    visible: viewModel.running
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
                    enabled: page.displayImageUrl.length > 0
                    onClicked: page.previewFullscreen = true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: page.displayImageUrl.length > 0
                      ? "Replace Image"
                      : (viewModel.mobilePlatform ? "Choose From Album" : "Choose Image")
                enabled: !viewModel.running
                onClicked: inputImageDialog.open()
            }

            Button {
                text: "Clear"
                enabled: !viewModel.running && page.displayImageUrl.length > 0
                onClicked: {
                    page.displayImageUrl = ""
                    page.waitingResult = false
                    previewErrorLabel.text = ""
                    viewModel.clearInputImages()
                }
            }

            Button {
                text: viewModel.mobilePlatform ? "Save To Album" : "Save Image"
                enabled: !viewModel.running && viewModel.canSaveImage
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

    Connections {
        target: viewModel

        function onPreviewImageUrlChanged() {
            if (page.waitingResult && viewModel.previewImageUrl.length > 0) {
                page.displayImageUrl = viewModel.previewImageUrl
                page.waitingResult = false
            }
        }

        function onStatusTextChanged() {
            if (!page.waitingResult) {
                return
            }

            if (viewModel.statusText === "Failed" || viewModel.statusText === "Done (No Preview)") {
                page.waitingResult = false
            }
        }
    }

    FileDialog {
        id: inputImageDialog
        title: viewModel.mobilePlatform ? "Select photo" : "Select input image"
        fileMode: FileDialog.OpenFile
        currentFolder: viewModel.mobilePlatform ? viewModel.photoPickerDirUrl : viewModel.outputDirUrl
        nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.bmp)", "All files (*)"]
        onAccepted: {
            let chosen = selectedFile
            if ((!chosen || chosen.toString().length === 0) && selectedFiles.length > 0) {
                chosen = selectedFiles[0]
            }

            if (!chosen || chosen.toString().length === 0) {
                return
            }

            page.displayImageUrl = chosen.toString()
            page.waitingResult = false
            previewErrorLabel.text = ""

            viewModel.clearInputImages()
            const added = viewModel.addInputImageUrl(chosen)
            if (!added) {
                return
            }

            page.waitingResult = true
            viewModel.runSimpleInference()
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: page.previewFullscreen
        z: 1000
        color: "#e6000000"

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
            source: page.displayImageUrl
            visible: page.displayImageUrl.length > 0
            scale: page.previewFullscreenScale
        }

        PinchArea {
            anchors.fill: parent
            enabled: page.displayImageUrl.length > 0

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
            color: "#ffffff"
            text: "Pinch to zoom, tap image to exit fullscreen"
            visible: page.displayImageUrl.length > 0
        }

        TapHandler {
            onTapped: page.previewFullscreen = false
        }
    }
}
