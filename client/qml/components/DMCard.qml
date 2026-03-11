import QtQuick
import "DMTheme.js" as DMTheme

Rectangle {
    id: card

    property color toneTop: DMTheme.color("cardToneTop")
    property color toneBottom: DMTheme.color("cardToneBottom")
    property color borderTone: DMTheme.color("cardBorder")

    radius: 18
    border.width: 1
    border.color: borderTone
    gradient: Gradient {
        GradientStop { position: 0.0; color: card.toneTop }
        GradientStop { position: 1.0; color: card.toneBottom }
    }
}
