import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent
    z: 1000
    visible: active

    property bool active: false
    property string imageUrl: ""
    property color overlayColor: "#D0000000"
    property color hintColor: "#F0FFFFFF"
    property string hintText: "Pinch to zoom, drag to pan, double-tap to toggle zoom, tap or X to exit fullscreen"
    property real minScale: 1.0
    property real maxScale: 6.0
    property real doubleTapScale: 2.4
    property real edgeResistance: 0.28
    property int settleDuration: 220
    property int zoomDuration: 180

    signal closeRequested()

    property real imageScale: 1.0
    property real panX: 0.0
    property real panY: 0.0
    property real pinchStartScale: 1.0
    property real pinchStartPanX: 0.0
    property real pinchStartPanY: 0.0
    property real dragStartPanX: 0.0
    property real dragStartPanY: 0.0
    property int pendingTapCount: 0
    property int animationDuration: settleDuration
    property real animationTargetScale: 1.0
    property real animationTargetPanX: 0.0
    property real animationTargetPanY: 0.0
    readonly property bool hasImage: imageUrl.length > 0

    function clamp(value, minValue, maxValue) {
        return Math.max(minValue, Math.min(maxValue, value))
    }

    function panLimitXFor(scaleValue) {
        const extraWidth = imageDisplay.paintedWidth * scaleValue - imageViewport.width
        return Math.max(0, extraWidth / 2)
    }

    function panLimitYFor(scaleValue) {
        const extraHeight = imageDisplay.paintedHeight * scaleValue - imageViewport.height
        return Math.max(0, extraHeight / 2)
    }

    function hardClampScale(value) {
        return clamp(value, minScale, maxScale)
    }

    function softClampScale(value) {
        if (value < minScale) {
            return minScale - (minScale - value) * edgeResistance
        }

        if (value > maxScale) {
            return maxScale + (value - maxScale) * edgeResistance
        }

        return value
    }

    function softClampPan(value, limit) {
        if (limit <= 0) {
            return value * edgeResistance
        }

        if (value < -limit) {
            return -limit - (-limit - value) * edgeResistance
        }

        if (value > limit) {
            return limit + (value - limit) * edgeResistance
        }

        return value
    }

    function applyPan(rawX, rawY, allowOverscroll) {
        const limitX = panLimitXFor(imageScale)
        const limitY = panLimitYFor(imageScale)

        if (allowOverscroll) {
            panX = softClampPan(rawX, limitX)
            panY = softClampPan(rawY, limitY)
            return
        }

        panX = clamp(rawX, -limitX, limitX)
        panY = clamp(rawY, -limitY, limitY)
    }

    function clampPan() {
        applyPan(panX, panY, false)
    }

    function stopAnimations() {
        if (reboundAnimation.running) {
            reboundAnimation.stop()
        }
    }

    function animateTo(scaleValue, panXValue, panYValue, durationValue) {
        stopAnimations()

        animationTargetScale = hardClampScale(scaleValue)

        const limitX = panLimitXFor(animationTargetScale)
        const limitY = panLimitYFor(animationTargetScale)
        animationTargetPanX = clamp(panXValue, -limitX, limitX)
        animationTargetPanY = clamp(panYValue, -limitY, limitY)
        animationDuration = Math.max(80, durationValue)

        reboundAnimation.restart()
    }

    function settleToBounds(animated) {
        const targetScale = hardClampScale(imageScale)
        const limitX = panLimitXFor(targetScale)
        const limitY = panLimitYFor(targetScale)
        const targetPanX = clamp(panX, -limitX, limitX)
        const targetPanY = clamp(panY, -limitY, limitY)

        if (animated) {
            animateTo(targetScale, targetPanX, targetPanY, settleDuration)
            return
        }

        imageScale = targetScale
        panX = targetPanX
        panY = targetPanY
    }

    function toggleDoubleTapZoom() {
        if (!hasImage) {
            closeRequested()
            return
        }

        const shouldZoomIn = imageScale <= 1.05 && Math.abs(panX) < 6 && Math.abs(panY) < 6

        if (shouldZoomIn) {
            const zoomInScale = hardClampScale(doubleTapScale)
            animateTo(zoomInScale, 0.0, 0.0, zoomDuration)
            return
        }

        animateTo(1.0, 0.0, 0.0, zoomDuration)
    }

    function resetView() {
        pendingTapCount = 0
        stopAnimations()
        imageScale = 1.0
        panX = 0.0
        panY = 0.0
    }

    onActiveChanged: {
        if (active) {
            resetView()
        } else {
            pendingTapCount = 0
            stopAnimations()
        }
    }

    onImageUrlChanged: {
        if (active) {
            resetView()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.overlayColor
    }

    ParallelAnimation {
        id: reboundAnimation

        NumberAnimation {
            target: root
            property: "imageScale"
            to: root.animationTargetScale
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "panX"
            to: root.animationTargetPanX
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "panY"
            to: root.animationTargetPanY
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }

        onStopped: root.settleToBounds(false)
    }

    Item {
        id: imageViewport
        anchors.fill: parent
        anchors.margins: 16
        clip: true

        onWidthChanged: root.settleToBounds(false)
        onHeightChanged: root.settleToBounds(false)

        Image {
            id: imageDisplay
            width: imageViewport.width
            height: imageViewport.height
            x: (imageViewport.width - width) / 2 + root.panX
            y: (imageViewport.height - height) / 2 + root.panY
            cache: false
            smooth: true
            fillMode: Image.PreserveAspectFit
            source: root.imageUrl
            visible: root.hasImage
            transformOrigin: Item.Center
            scale: root.imageScale

            onPaintedWidthChanged: root.settleToBounds(false)
            onPaintedHeightChanged: root.settleToBounds(false)
        }

        Label {
            anchors.centerIn: parent
            text: "No image to preview"
            color: root.hintColor
            visible: !root.hasImage
        }
    }

    PinchHandler {
        id: pinchHandler
        enabled: root.active && root.hasImage
        target: null

        onActiveChanged: {
            if (active) {
                root.stopAnimations()
                root.pinchStartScale = root.imageScale
                root.pinchStartPanX = root.panX
                root.pinchStartPanY = root.panY
            } else {
                root.settleToBounds(true)
            }
        }

        onScaleChanged: {
            const scaled = root.pinchStartScale * scale
            root.imageScale = root.softClampScale(scaled)

            const rawX = root.pinchStartPanX + translation.x
            const rawY = root.pinchStartPanY + translation.y
            root.applyPan(rawX, rawY, true)
        }

        onTranslationChanged: {
            const rawX = root.pinchStartPanX + translation.x
            const rawY = root.pinchStartPanY + translation.y
            root.applyPan(rawX, rawY, true)
        }
    }

    DragHandler {
        id: dragHandler
        enabled: root.active && root.hasImage && !pinchHandler.active
        target: null
        acceptedDevices: PointerDevice.TouchScreen | PointerDevice.Mouse | PointerDevice.TouchPad

        onActiveChanged: {
            if (active) {
                root.stopAnimations()
                root.dragStartPanX = root.panX
                root.dragStartPanY = root.panY
            } else {
                root.settleToBounds(true)
            }
        }

        onTranslationChanged: {
            const rawX = root.dragStartPanX + translation.x
            const rawY = root.dragStartPanY + translation.y
            root.applyPan(rawX, rawY, true)
        }
    }

    Timer {
        id: singleTapDelay
        interval: 260
        repeat: false

        onTriggered: {
            if (root.pendingTapCount === 1) {
                root.closeRequested()
            }

            root.pendingTapCount = 0
        }
    }

    TapHandler {
        enabled: root.active
        acceptedDevices: PointerDevice.TouchScreen | PointerDevice.Mouse | PointerDevice.Stylus | PointerDevice.TouchPad
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.ReleaseWithinBounds

        onTapped: {
            if (pinchHandler.active || dragHandler.active) {
                return
            }

            root.pendingTapCount += 1

            if (root.pendingTapCount === 1) {
                singleTapDelay.restart()
                return
            }

            singleTapDelay.stop()
            root.pendingTapCount = 0
            root.toggleDoubleTapZoom()
        }
    }

    RoundButton {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 20
        anchors.rightMargin: 20
        text: "\u2715"
        visible: root.hasImage
        z: 2
        onClicked: root.closeRequested()
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        color: root.hintColor
        text: root.hintText
        visible: root.hasImage
    }
}
