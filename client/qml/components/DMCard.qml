import QtQuick
import QtQuick.Controls
import "DMTheme.js" as DMTheme

Rectangle {
    id: card
    property string themeName: ""
    readonly property string dmThemeName: themeName.length > 0
                                          ? themeName
                                          : ((ApplicationWindow.window && ApplicationWindow.window.dmThemeName)
                                             ? ApplicationWindow.window.dmThemeName
                                             : "ocean")

    property color toneTop: DMTheme.colorFor(card.dmThemeName, "cardToneTop")
    property color toneBottom: DMTheme.colorFor(card.dmThemeName, "cardToneBottom")
    property color borderTone: DMTheme.colorFor(card.dmThemeName, "cardBorder")

    radius: 18
    border.width: 1
    border.color: borderTone
    gradient: Gradient {
        GradientStop { position: 0.0; color: card.toneTop }
        GradientStop { position: 1.0; color: card.toneBottom }
    }
}
