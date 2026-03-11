var currentThemeName = "ocean";

var themes = {
    ocean: {
        cardToneTop: "#1a2c3e",
        cardToneBottom: "#122030",
        cardBorder: "#31506a",

        buttonText: "#f2f7fd",
        buttonDisabledBorder: "#44617a",
        buttonDisabledTop: "#2f4356",
        buttonDisabledBottom: "#27394a",

        buttonNormalBorder: "#56748f",
        buttonNormalBorderDown: "#6c88a3",
        buttonNormalTop: "#375875",
        buttonNormalTopDown: "#2d4962",
        buttonNormalBottom: "#2f4c66",
        buttonNormalBottomDown: "#273f56",

        buttonPrimaryBorder: "#4be8c1",
        buttonPrimaryBorderDown: "#66f8d2",
        buttonPrimaryTop: "#15927d",
        buttonPrimaryTopDown: "#117b69",
        buttonPrimaryBottom: "#127565",
        buttonPrimaryBottomDown: "#0e6558",

        buttonDangerBorder: "#ff6e7d",
        buttonDangerBorderDown: "#ff8a96",
        buttonDangerTop: "#a6384c",
        buttonDangerTopDown: "#8e2f40",
        buttonDangerBottom: "#8f3042",
        buttonDangerBottomDown: "#772636",

        fieldTextEnabled: "#edf4fd",
        fieldTextDisabled: "#9cb2c6",
        fieldSelection: "#2aa58a",
        fieldSelectedText: "#ffffff",
        fieldPlaceholder: "#7f99af",
        fieldBorder: "#3f5e79",
        fieldBorderFocus: "#4fe3be",
        fieldBgTop: "#162838",
        fieldBgBottom: "#112131",

        spinIndicatorBorder: "#4c789a",
        spinIndicatorBorderPressed: "#6bb4e3",
        spinIndicatorTop: "#35688d",
        spinIndicatorTopPressed: "#2b5c7f",
        spinIndicatorBottom: "#2a5674",
        spinIndicatorBottomPressed: "#224b68",
        spinIndicatorText: "#eff6ff",

        sliderTrackBorder: "#42617d",
        sliderTrackTop: "#1b3145",
        sliderTrackBottom: "#172b3d",
        sliderFillBorder: "#71e9c8",
        sliderFillTop: "#179a83",
        sliderFillBottom: "#127966",
        sliderHandleBorder: "#6bd8bc",
        sliderHandleBorderPressed: "#9ef6de",
        sliderHandleTop: "#2fb695",
        sliderHandleTopPressed: "#3ec6a8",
        sliderHandleBottom: "#268d74",
        sliderHandleBottomPressed: "#2da286"
    },

    sunset: {
        cardToneTop: "#3a2430",
        cardToneBottom: "#261b2b",
        cardBorder: "#7a4f67",

        buttonNormalBorder: "#c58f66",
        buttonNormalBorderDown: "#d9a77f",
        buttonNormalTop: "#8a5a42",
        buttonNormalTopDown: "#734836",
        buttonNormalBottom: "#6f4736",
        buttonNormalBottomDown: "#5e3b2f",

        buttonPrimaryBorder: "#ffcc6a",
        buttonPrimaryBorderDown: "#ffe18f",
        buttonPrimaryTop: "#c8842a",
        buttonPrimaryTopDown: "#aa6f1f",
        buttonPrimaryBottom: "#a5661b",
        buttonPrimaryBottomDown: "#8e5618",

        buttonDangerBorder: "#ff8f7c",
        buttonDangerBorderDown: "#ffac9e",
        buttonDangerTop: "#b64a44",
        buttonDangerTopDown: "#993c37",
        buttonDangerBottom: "#9b3f3a",
        buttonDangerBottomDown: "#803430",

        fieldTextEnabled: "#fff2ec",
        fieldTextDisabled: "#d1b7ad",
        fieldSelection: "#d78b4a",
        fieldPlaceholder: "#b7988a",
        fieldBorder: "#7b5c66",
        fieldBorderFocus: "#ffcc6a",
        fieldBgTop: "#3a2732",
        fieldBgBottom: "#2c1f28",

        spinIndicatorBorder: "#b78964",
        spinIndicatorBorderPressed: "#d3a27a",
        spinIndicatorTop: "#8f6244",
        spinIndicatorTopPressed: "#764f36",
        spinIndicatorBottom: "#754e36",
        spinIndicatorBottomPressed: "#603f2c",
        spinIndicatorText: "#fff4e8",

        sliderTrackBorder: "#8a6b5f",
        sliderTrackTop: "#4a3140",
        sliderTrackBottom: "#3b2935",
        sliderFillBorder: "#ffd07a",
        sliderFillTop: "#cf8b2a",
        sliderFillBottom: "#ad6f1f",
        sliderHandleBorder: "#ffde95",
        sliderHandleBorderPressed: "#fff0bf",
        sliderHandleTop: "#d39235",
        sliderHandleTopPressed: "#e2a74f",
        sliderHandleBottom: "#af7124",
        sliderHandleBottomPressed: "#c38435"
    },

    forest: {
        cardToneTop: "#1c3328",
        cardToneBottom: "#13261d",
        cardBorder: "#3f7059",

        buttonNormalBorder: "#6b907c",
        buttonNormalBorderDown: "#84aa95",
        buttonNormalTop: "#355a49",
        buttonNormalTopDown: "#2b4b3d",
        buttonNormalBottom: "#2d4e40",
        buttonNormalBottomDown: "#254236",

        buttonPrimaryBorder: "#88e2b5",
        buttonPrimaryBorderDown: "#a8f0cb",
        buttonPrimaryTop: "#2c9e73",
        buttonPrimaryTopDown: "#22855f",
        buttonPrimaryBottom: "#227f5b",
        buttonPrimaryBottomDown: "#1b6b4d",

        buttonDangerBorder: "#e67d73",
        buttonDangerBorderDown: "#f09a90",
        buttonDangerTop: "#944842",
        buttonDangerTopDown: "#7d3b36",
        buttonDangerBottom: "#7b3c37",
        buttonDangerBottomDown: "#65312d",

        fieldTextEnabled: "#ebfbf2",
        fieldTextDisabled: "#9ebcad",
        fieldSelection: "#36a879",
        fieldPlaceholder: "#7ea08e",
        fieldBorder: "#4c7663",
        fieldBorderFocus: "#8ae3b8",
        fieldBgTop: "#193126",
        fieldBgBottom: "#14261e",

        spinIndicatorBorder: "#5f8f79",
        spinIndicatorBorderPressed: "#79b89a",
        spinIndicatorTop: "#3d694f",
        spinIndicatorTopPressed: "#335943",
        spinIndicatorBottom: "#31553f",
        spinIndicatorBottomPressed: "#294735",
        spinIndicatorText: "#edfff3",

        sliderTrackBorder: "#4b7561",
        sliderTrackTop: "#1f3a2d",
        sliderTrackBottom: "#183126",
        sliderFillBorder: "#8de5bb",
        sliderFillTop: "#2d9f74",
        sliderFillBottom: "#237f5d",
        sliderHandleBorder: "#88d9b3",
        sliderHandleBorderPressed: "#b0eed0",
        sliderHandleTop: "#38b182",
        sliderHandleTopPressed: "#4ac293",
        sliderHandleBottom: "#2a8c68",
        sliderHandleBottomPressed: "#39a47d"
    },

    graphite: {
        cardToneTop: "#2a2f38",
        cardToneBottom: "#1e232b",
        cardBorder: "#596271",

        buttonText: "#f4f6fb",
        buttonDisabledBorder: "#555f70",
        buttonDisabledTop: "#3a4250",
        buttonDisabledBottom: "#323947",

        buttonNormalBorder: "#7d889a",
        buttonNormalBorderDown: "#95a1b4",
        buttonNormalTop: "#4f5868",
        buttonNormalTopDown: "#454d5d",
        buttonNormalBottom: "#444c5b",
        buttonNormalBottomDown: "#39414f",

        buttonPrimaryBorder: "#7fb0ff",
        buttonPrimaryBorderDown: "#a2c7ff",
        buttonPrimaryTop: "#4a76c6",
        buttonPrimaryTopDown: "#3f66ac",
        buttonPrimaryBottom: "#3f66a8",
        buttonPrimaryBottomDown: "#355590",

        buttonDangerBorder: "#ff8898",
        buttonDangerBorderDown: "#ff9eac",
        buttonDangerTop: "#a84a5a",
        buttonDangerTopDown: "#8e3d4c",
        buttonDangerBottom: "#903f4f",
        buttonDangerBottomDown: "#763441",

        fieldTextEnabled: "#f2f5fb",
        fieldTextDisabled: "#afb7c8",
        fieldSelection: "#5f89e2",
        fieldPlaceholder: "#9ca7b9",
        fieldBorder: "#697485",
        fieldBorderFocus: "#8cb3ff",
        fieldBgTop: "#2b323e",
        fieldBgBottom: "#232933",

        spinIndicatorBorder: "#788498",
        spinIndicatorBorderPressed: "#97a6be",
        spinIndicatorTop: "#516076",
        spinIndicatorTopPressed: "#465268",
        spinIndicatorBottom: "#465467",
        spinIndicatorBottomPressed: "#3c485b",
        spinIndicatorText: "#f3f7ff",

        sliderTrackBorder: "#667285",
        sliderTrackTop: "#303846",
        sliderTrackBottom: "#2a313e",
        sliderFillBorder: "#8db8ff",
        sliderFillTop: "#557fcd",
        sliderFillBottom: "#466db2",
        sliderHandleBorder: "#93b9ff",
        sliderHandleBorderPressed: "#b6d2ff",
        sliderHandleTop: "#5e88d6",
        sliderHandleTopPressed: "#719be5",
        sliderHandleBottom: "#4b74bc",
        sliderHandleBottomPressed: "#5f86d0"
    }
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

function color(role) {
    var palette = themes[currentThemeName] || themes.ocean;
    if (palette[role] !== undefined) {
        return palette[role];
    }

    if (themes.ocean[role] !== undefined) {
        return themes.ocean[role];
    }

    console.warn("DMTheme: unknown role", role);
    return "#ff00ff";
}

function fieldText(enabled) {
    return enabled ? color("fieldTextEnabled") : color("fieldTextDisabled");
}

function buttonBorder(enabled, primary, danger, down) {
    if (!enabled) {
        return color("buttonDisabledBorder");
    }

    if (primary) {
        return down ? color("buttonPrimaryBorderDown") : color("buttonPrimaryBorder");
    }

    if (danger) {
        return down ? color("buttonDangerBorderDown") : color("buttonDangerBorder");
    }

    return down ? color("buttonNormalBorderDown") : color("buttonNormalBorder");
}

function buttonTop(enabled, primary, danger, down) {
    if (!enabled) {
        return color("buttonDisabledTop");
    }

    if (primary) {
        return down ? color("buttonPrimaryTopDown") : color("buttonPrimaryTop");
    }

    if (danger) {
        return down ? color("buttonDangerTopDown") : color("buttonDangerTop");
    }

    return down ? color("buttonNormalTopDown") : color("buttonNormalTop");
}

function buttonBottom(enabled, primary, danger, down) {
    if (!enabled) {
        return color("buttonDisabledBottom");
    }

    if (primary) {
        return down ? color("buttonPrimaryBottomDown") : color("buttonPrimaryBottom");
    }

    if (danger) {
        return down ? color("buttonDangerBottomDown") : color("buttonDangerBottom");
    }

    return down ? color("buttonNormalBottomDown") : color("buttonNormalBottom");
}

function spinIndicatorBorder(enabled, pressed) {
    if (!enabled) {
        return color("buttonDisabledBorder");
    }

    return pressed ? color("spinIndicatorBorderPressed") : color("spinIndicatorBorder");
}

function spinIndicatorTop(enabled, pressed) {
    if (!enabled) {
        return color("buttonDisabledTop");
    }

    return pressed ? color("spinIndicatorTopPressed") : color("spinIndicatorTop");
}

function spinIndicatorBottom(enabled, pressed) {
    if (!enabled) {
        return color("buttonDisabledBottom");
    }

    return pressed ? color("spinIndicatorBottomPressed") : color("spinIndicatorBottom");
}

function sliderHandleBorder(pressed) {
    return pressed ? color("sliderHandleBorderPressed") : color("sliderHandleBorder");
}

function sliderHandleTop(pressed) {
    return pressed ? color("sliderHandleTopPressed") : color("sliderHandleTop");
}

function sliderHandleBottom(pressed) {
    return pressed ? color("sliderHandleBottomPressed") : color("sliderHandleBottom");
}
