.import "themes/ocean.js" as OceanTheme
.import "themes/sunset.js" as SunsetTheme
.import "themes/forest.js" as ForestTheme
.import "themes/graphite.js" as GraphiteTheme

var currentThemeName = "ocean";

var themes = {
    ocean: OceanTheme.palette,
    sunset: SunsetTheme.palette,
    forest: ForestTheme.palette,
    graphite: GraphiteTheme.palette
};

function setTheme(name) {
    if (themes[name] !== undefined) {
        currentThemeName = name;
    } else {
        console.warn("DMTheme: unknown theme", name);
    }
}

function themeNames() {
    return Object.keys(themes);
}

function resolvePalette(themeName) {
    if (themeName !== undefined && themes[themeName] !== undefined) {
        return themes[themeName];
    }

    if (themes[currentThemeName] !== undefined) {
        return themes[currentThemeName];
    }

    return themes.ocean;
}

function color(role, themeName) {
    var palette = resolvePalette(themeName);
    if (palette[role] !== undefined) {
        return palette[role];
    }

    if (themes.ocean[role] !== undefined) {
        return themes.ocean[role];
    }

    console.warn("DMTheme: unknown role", role);
    return "#ff00ff";
}

function colorFor(themeName, role) {
    return color(role, themeName);
}

function fieldTextFor(themeName, enabled) {
    return enabled ? color("fieldTextEnabled", themeName) : color("fieldTextDisabled", themeName);
}

function buttonBorderFor(themeName, enabled, primary, danger, down) {
    if (!enabled) {
        return color("buttonDisabledBorder", themeName);
    }

    if (primary) {
        return down ? color("buttonPrimaryBorderDown", themeName) : color("buttonPrimaryBorder", themeName);
    }

    if (danger) {
        return down ? color("buttonDangerBorderDown", themeName) : color("buttonDangerBorder", themeName);
    }

    return down ? color("buttonNormalBorderDown", themeName) : color("buttonNormalBorder", themeName);
}

function buttonTopFor(themeName, enabled, primary, danger, down) {
    if (!enabled) {
        return color("buttonDisabledTop", themeName);
    }

    if (primary) {
        return down ? color("buttonPrimaryTopDown", themeName) : color("buttonPrimaryTop", themeName);
    }

    if (danger) {
        return down ? color("buttonDangerTopDown", themeName) : color("buttonDangerTop", themeName);
    }

    return down ? color("buttonNormalTopDown", themeName) : color("buttonNormalTop", themeName);
}

function buttonBottomFor(themeName, enabled, primary, danger, down) {
    if (!enabled) {
        return color("buttonDisabledBottom", themeName);
    }

    if (primary) {
        return down ? color("buttonPrimaryBottomDown", themeName) : color("buttonPrimaryBottom", themeName);
    }

    if (danger) {
        return down ? color("buttonDangerBottomDown", themeName) : color("buttonDangerBottom", themeName);
    }

    return down ? color("buttonNormalBottomDown", themeName) : color("buttonNormalBottom", themeName);
}

function spinIndicatorBorderFor(themeName, enabled, pressed) {
    if (!enabled) {
        return color("buttonDisabledBorder", themeName);
    }

    return pressed ? color("spinIndicatorBorderPressed", themeName) : color("spinIndicatorBorder", themeName);
}

function spinIndicatorTopFor(themeName, enabled, pressed) {
    if (!enabled) {
        return color("buttonDisabledTop", themeName);
    }

    return pressed ? color("spinIndicatorTopPressed", themeName) : color("spinIndicatorTop", themeName);
}

function spinIndicatorBottomFor(themeName, enabled, pressed) {
    if (!enabled) {
        return color("buttonDisabledBottom", themeName);
    }

    return pressed ? color("spinIndicatorBottomPressed", themeName) : color("spinIndicatorBottom", themeName);
}

function sliderHandleBorderFor(themeName, pressed) {
    return pressed ? color("sliderHandleBorderPressed", themeName) : color("sliderHandleBorder", themeName);
}

function sliderHandleTopFor(themeName, pressed) {
    return pressed ? color("sliderHandleTopPressed", themeName) : color("sliderHandleTop", themeName);
}

function sliderHandleBottomFor(themeName, pressed) {
    return pressed ? color("sliderHandleBottomPressed", themeName) : color("sliderHandleBottom", themeName);
}

function fieldText(enabled) {
    return fieldTextFor(undefined, enabled);
}

function buttonBorder(enabled, primary, danger, down) {
    return buttonBorderFor(undefined, enabled, primary, danger, down);
}

function buttonTop(enabled, primary, danger, down) {
    return buttonTopFor(undefined, enabled, primary, danger, down);
}

function buttonBottom(enabled, primary, danger, down) {
    return buttonBottomFor(undefined, enabled, primary, danger, down);
}

function spinIndicatorBorder(enabled, pressed) {
    return spinIndicatorBorderFor(undefined, enabled, pressed);
}

function spinIndicatorTop(enabled, pressed) {
    return spinIndicatorTopFor(undefined, enabled, pressed);
}

function spinIndicatorBottom(enabled, pressed) {
    return spinIndicatorBottomFor(undefined, enabled, pressed);
}

function sliderHandleBorder(pressed) {
    return sliderHandleBorderFor(undefined, pressed);
}

function sliderHandleTop(pressed) {
    return sliderHandleTopFor(undefined, pressed);
}

function sliderHandleBottom(pressed) {
    return sliderHandleBottomFor(undefined, pressed);
}
