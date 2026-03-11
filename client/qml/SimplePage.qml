import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: page
    anchors.fill: parent

    property string originalImageUrl: ""
    property string generatedImageUrl: ""
    property bool waitingResult: false
    property bool previewFullscreen: false
    property real previewFullscreenScale: 1.0
    property real previewPinchStartScale: 1.0
    property string originalPreviewError: ""
    property string generatedPreviewError: ""
    readonly property string currentPreviewUrl: previewSwipe.currentIndex === 0
                                              ? originalImageUrl
                                              : generatedImageUrl
    readonly property string currentPreviewError: previewSwipe.currentIndex === 0
                                                ? originalPreviewError
                                                : generatedPreviewError

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
                    text: "Select one input image. The app will run using your current Advanced mode parameters. Swipe left/right in preview to switch between Original and Generated."
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

                SwipeView {
                    id: previewSwipe
                    anchors.fill: parent
                    anchors.margins: 8
                    interactive: true
                    clip: true

                    Item {
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"

                            Rectangle {
                                z: 3
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.margins: 8
                                radius: 8
                                color: "#f2f8fd"
                                border.color: "#cfe0ec"
                                implicitWidth: originalBadgeLabel.implicitWidth + 14
                                implicitHeight: originalBadgeLabel.implicitHeight + 6

                                Label {
                                    id: originalBadgeLabel
                                    anchors.centerIn: parent
                                    text: "Original"
                                    color: "#1f3a4a"
                                    font.bold: true
                                }
                            }

                            Image {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                anchors.bottomMargin: 12
                                anchors.topMargin: 38
                                cache: false
                                smooth: true
                                fillMode: Image.PreserveAspectFit
                                source: page.originalImageUrl
                                visible: page.originalImageUrl.length > 0

                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        page.originalPreviewError = "Original preview load failed: " + source
                                    } else if (status === Image.Ready) {
                                        page.originalPreviewError = ""
                                    }
                                }
                            }

                            Label {
                                anchors.centerIn: parent
                                text: "No original image selected"
                                color: "#6a8294"
                                visible: page.originalImageUrl.length === 0
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: page.originalImageUrl.length > 0
                                preventStealing: false
                                onClicked: page.previewFullscreen = true
                            }
                        }
                    }

                    Item {
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"

                            Rectangle {
                                z: 3
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.margins: 8
                                radius: 8
                                color: "#f2f8fd"
                                border.color: "#cfe0ec"
                                implicitWidth: generatedBadgeLabel.implicitWidth + 14
                                implicitHeight: generatedBadgeLabel.implicitHeight + 6

                                Label {
                                    id: generatedBadgeLabel
                                    anchors.centerIn: parent
                                    text: "Generated"
                                    color: "#1f3a4a"
                                    font.bold: true
                                }
                            }

                            Image {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                anchors.bottomMargin: 12
                                anchors.topMargin: 38
                                cache: false
                                smooth: true
                                fillMode: Image.PreserveAspectFit
                                source: page.generatedImageUrl
                                visible: page.generatedImageUrl.length > 0

                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        page.generatedPreviewError = "Generated preview load failed: " + source
                                    } else if (status === Image.Ready) {
                                        page.generatedPreviewError = ""
                                    }
                                }
                            }

                            Label {
                                anchors.centerIn: parent
                                text: viewModel.running && page.waitingResult
                                      ? "Generating..."
                                      : "No generated image yet"
                                color: "#6a8294"
                                visible: page.generatedImageUrl.length === 0
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: page.generatedImageUrl.length > 0
                                preventStealing: false
                                onClicked: page.previewFullscreen = true
                            }
                        }
                    }
                }

                PageIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8
                    count: 2
                    currentIndex: previewSwipe.currentIndex
                }

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 28
                    horizontalAlignment: Text.AlignHCenter
                    text: "Swipe left/right to switch, tap image for fullscreen"
                    color: "#6a8294"
                    font.pixelSize: 12
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
                    visible: page.currentPreviewError.length > 0
                    text: page.currentPreviewError
                }

            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: page.originalImageUrl.length > 0
                      ? "Replace Image"
                      : (viewModel.mobilePlatform ? "Choose From Album" : "Choose Image")
                enabled: !viewModel.running
                onClicked: inputImageDialog.open()
            }

            Button {
                text: "Clear"
                enabled: !viewModel.running
                         && (page.originalImageUrl.length > 0 || page.generatedImageUrl.length > 0)
                onClicked: {
                    page.originalImageUrl = ""
                    page.generatedImageUrl = ""
                    page.waitingResult = false
                    page.originalPreviewError = ""
                    page.generatedPreviewError = ""
                    previewSwipe.currentIndex = 0
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
                page.generatedImageUrl = viewModel.previewImageUrl
                page.generatedPreviewError = ""
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

            page.originalImageUrl = chosen.toString()
            page.generatedImageUrl = ""
            page.waitingResult = false
            page.originalPreviewError = ""
            page.generatedPreviewError = ""
            previewSwipe.currentIndex = 0

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
            source: page.currentPreviewUrl
            visible: page.currentPreviewUrl.length > 0
            scale: page.previewFullscreenScale
        }

        PinchArea {
            anchors.fill: parent
            enabled: page.currentPreviewUrl.length > 0

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
            visible: page.currentPreviewUrl.length > 0
        }

        TapHandler {
            onTapped: page.previewFullscreen = false
        }
    }
}
