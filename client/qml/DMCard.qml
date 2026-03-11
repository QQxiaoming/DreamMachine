import QtQuick

Rectangle {
    id: card

    property color toneTop: "#1a2c3e"
    property color toneBottom: "#122030"
    property color borderTone: "#31506a"

    radius: 18
    border.width: 1
    border.color: borderTone
    gradient: Gradient {
        GradientStop { position: 0.0; color: card.toneTop }
        GradientStop { position: 1.0; color: card.toneBottom }
    }
}
