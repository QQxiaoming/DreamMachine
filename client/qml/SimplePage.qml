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

        DMCard {
            Layout.fillWidth: true
            implicitHeight: statusContent.implicitHeight + 20
            radius: 18

            ColumnLayout {
                id: statusContent
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6

                Label {
                    text: "Status: " + viewModel.statusText
                    font.bold: true
                    color: "#f0f7ff"
                }

                Label {
                    visible: viewModel.lastError.length > 0
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    color: "#ff7f90"
                    text: viewModel.lastError
                }
            }
        }

        DMCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 18

            Rectangle {
                anchors.fill: parent
                anchors.margins: 10
                radius: 14
                border.color: "#3b5a76"
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#172938" }
                    GradientStop { position: 1.0; color: "#132435" }
                }

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
                                border.color: "#67a7d4"
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#2f5d7f" }
                                    GradientStop { position: 1.0; color: "#274f6d" }
                                }
                                implicitWidth: originalBadgeLabel.implicitWidth + 14
                                implicitHeight: originalBadgeLabel.implicitHeight + 6

                                Label {
                                    id: originalBadgeLabel
                                    anchors.centerIn: parent
                                    text: "Original"
                                    color: "#e3edf8"
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
                                color: "#8ea5bb"
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
                                border.color: "#67a7d4"
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#2f5d7f" }
                                    GradientStop { position: 1.0; color: "#274f6d" }
                                }
                                implicitWidth: generatedBadgeLabel.implicitWidth + 14
                                implicitHeight: generatedBadgeLabel.implicitHeight + 6

                                Label {
                                    id: generatedBadgeLabel
                                    anchors.centerIn: parent
                                    text: "Generated"
                                    color: "#e3edf8"
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
                                color: "#8ea5bb"
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

                    delegate: Rectangle {
                        implicitWidth: 9
                        implicitHeight: 9
                        radius: 5
                        color: index === previewSwipe.currentIndex ? "#63ddbc" : "#48637c"
                        opacity: 0.95
                    }
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
                    color: "#ff7f90"
                    wrapMode: Text.Wrap
                    visible: page.currentPreviewError.length > 0 || viewModel.lastError.length > 0
                    text: page.currentPreviewError.length > 0
                          ? page.currentPreviewError
                          : viewModel.lastError
                }

            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            DMButton {
                Layout.fillWidth: true
                text: page.originalImageUrl.length > 0 ? "\u21BB" : "\uff0b"
                primary: true
                font.pixelSize: 20
                enabled: !viewModel.running
                ToolTip.visible: hovered
                ToolTip.text: page.originalImageUrl.length > 0
                              ? "Replace image"
                              : (viewModel.mobilePlatform ? "Choose from album" : "Choose image")
                onClicked: inputImageDialog.open()
            }

            DMButton {
                Layout.fillWidth: true
                text: "\u2715"
                danger: true
                font.pixelSize: 20
                enabled: !viewModel.running
                            && (page.originalImageUrl.length > 0 || page.generatedImageUrl.length > 0)
                ToolTip.visible: hovered
                ToolTip.text: "Clear images"
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

            DMButton {
                Layout.fillWidth: true
                text: "\u2193"
                font.pixelSize: 20
                enabled: !viewModel.running && viewModel.canSaveImage
                ToolTip.visible: hovered
                ToolTip.text: viewModel.mobilePlatform ? "Save to album" : "Save image"
                onClicked: {
                    if (viewModel.mobilePlatform) {
                        viewModel.saveGeneratedImageToAlbum()
                    } else {
                        viewModel.saveGeneratedImage()
                    }
                }
            }

            DMButton {
                Layout.fillWidth: true
                text: "\u21C4"
                font.pixelSize: 20
                enabled: !viewModel.running
                            && viewModel.canSaveImage
                            && page.originalImageUrl.length > 0
                            && page.generatedImageUrl.length > 0
                ToolTip.visible: hovered
                ToolTip.text: viewModel.mobilePlatform ? "Save compare to album" : "Save compare"
                onClicked: {
                    if (viewModel.mobilePlatform) {
                        viewModel.saveComparisonImageToAlbum(page.originalImageUrl)
                    } else {
                        viewModel.saveComparisonImage(page.originalImageUrl)
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
            color: "#e6eef8"
            text: "Pinch to zoom, tap image to exit fullscreen"
            visible: page.currentPreviewUrl.length > 0
        }

        TapHandler {
            onTapped: page.previewFullscreen = false
        }
    }
}
