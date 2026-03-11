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
        sliderHandleBottomPressed: "#2da286",

        previewSurfaceBorder: "#3b5a76",
        previewSurfaceTop: "#172938",
        previewSurfaceBottom: "#132435",
        previewBadgeBorder: "#67a7d4",
        previewBadgeTop: "#2f5d7f",
        previewBadgeBottom: "#274f6d",
        previewBadgeText: "#e3edf8",
        previewHintText: "#8ea5bb",
        previewIndicatorActive: "#63ddbc",
        previewIndicatorInactive: "#48637c",
        previewErrorText: "#ff7f90",
        previewFullscreenOverlay: "#cc000000",
        previewFullscreenHint: "#e6eef8",

        mainBgTop: "#0d1724",
        mainBgMid: "#101f2f",
        mainBgBottom: "#11273c",
        mainBlobTopRight: "#331d455f",
        mainBlobBottomLeft: "#1f0f7f67",

        headerTop: "#192e41",
        headerBottom: "#132334",
        headerBorder: "#365470",

        menuButtonBorder: "#5f89ab",
        menuButtonBorderDown: "#7ec2ea",
        menuButtonTop: "#3b6d90",
        menuButtonTopDown: "#2f5f80",
        menuButtonBottom: "#2d5b7a",
        menuButtonBottomDown: "#244c69",

        titleText: "#d8e8f8",

        statusRunningTop: "#1f6650",
        statusRunningBottom: "#165241",
        statusRunningBorder: "#66d3aa",
        statusIdleTop: "#2b4b67",
        statusIdleBottom: "#233d54",
        statusIdleBorder: "#6ba7d1",
        statusText: "#edf5ff",

        drawerTop: "#13263a",
        drawerBottom: "#0f1d2c",
        drawerBorder: "#3e617f",
        drawerOverlay: "#b3000000",

        textPrimary: "#f0f7ff",
        textSecondary: "#b7cbde",
        textError: "#ff7f90",
        drawerTitleText: "#e3edf8",
        drawerSubtitleText: "#b4cade",

        listRowBorder: "#4a6b87",
        listRowTop: "#21394d",
        listRowBottom: "#1a2e40",
        listRowText: "#e0edf9"
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
        sliderHandleBottomPressed: "#c38435",

        previewSurfaceBorder: "#7f5a63",
        previewSurfaceTop: "#3a2732",
        previewSurfaceBottom: "#2d1f29",
        previewBadgeBorder: "#d5a27c",
        previewBadgeTop: "#8f6244",
        previewBadgeBottom: "#754e36",
        previewBadgeText: "#fff0e6",
        previewHintText: "#c6a194",
        previewIndicatorActive: "#ffd07a",
        previewIndicatorInactive: "#7f6464",
        previewErrorText: "#ff8f7c",
        previewFullscreenOverlay: "#cc170f14",
        previewFullscreenHint: "#ffece3",

        mainBgTop: "#271920",
        mainBgMid: "#33202a",
        mainBgBottom: "#3a2430",
        mainBlobTopRight: "#40ad6f40",
        mainBlobBottomLeft: "#33e7b26a",

        headerTop: "#4a2f3c",
        headerBottom: "#392432",
        headerBorder: "#8f5f74",

        menuButtonBorder: "#c99772",
        menuButtonBorderDown: "#e3b086",
        menuButtonTop: "#8f6045",
        menuButtonTopDown: "#7a4f37",
        menuButtonBottom: "#754a36",
        menuButtonBottomDown: "#643f2f",

        titleText: "#ffe9df",

        statusRunningTop: "#87692e",
        statusRunningBottom: "#6e5626",
        statusRunningBorder: "#ffd07a",
        statusIdleTop: "#654a5d",
        statusIdleBottom: "#543d4e",
        statusIdleBorder: "#d09eb8",
        statusText: "#fff3ea",

        drawerTop: "#3f2835",
        drawerBottom: "#311f2a",
        drawerBorder: "#81556a",
        drawerOverlay: "#b3120c10",

        textPrimary: "#fff3ea",
        textSecondary: "#d8b7aa",
        textError: "#ff8f7c",
        drawerTitleText: "#ffe9df",
        drawerSubtitleText: "#d7b3a5",

        listRowBorder: "#8e6b63",
        listRowTop: "#533540",
        listRowBottom: "#422b35",
        listRowText: "#fff0e6"
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
        sliderHandleBottomPressed: "#39a47d",

        previewSurfaceBorder: "#4b7561",
        previewSurfaceTop: "#1f3a2d",
        previewSurfaceBottom: "#183126",
        previewBadgeBorder: "#8bc9ad",
        previewBadgeTop: "#3d694f",
        previewBadgeBottom: "#31553f",
        previewBadgeText: "#edfff3",
        previewHintText: "#9cc2b0",
        previewIndicatorActive: "#8de5bb",
        previewIndicatorInactive: "#4a6d5c",
        previewErrorText: "#f09a90",
        previewFullscreenOverlay: "#cc0e1713",
        previewFullscreenHint: "#edfff3",

        mainBgTop: "#14271e",
        mainBgMid: "#1a3126",
        mainBgBottom: "#1f3b2d",
        mainBlobTopRight: "#333f8d6f",
        mainBlobBottomLeft: "#2f2fb07d",

        headerTop: "#1f3a2d",
        headerBottom: "#182d23",
        headerBorder: "#4f826d",

        menuButtonBorder: "#6f9d87",
        menuButtonBorderDown: "#8fc6aa",
        menuButtonTop: "#446f5a",
        menuButtonTopDown: "#395f4d",
        menuButtonBottom: "#345844",
        menuButtonBottomDown: "#2b4b3a",

        titleText: "#e8fff1",

        statusRunningTop: "#2b805d",
        statusRunningBottom: "#23694e",
        statusRunningBorder: "#8de5bb",
        statusIdleTop: "#365b4a",
        statusIdleBottom: "#2d4d3f",
        statusIdleBorder: "#7fb69d",
        statusText: "#edfff3",

        drawerTop: "#1d3529",
        drawerBottom: "#172b22",
        drawerBorder: "#4a7a65",
        drawerOverlay: "#b20b1511",

        textPrimary: "#edfff3",
        textSecondary: "#a8cab9",
        textError: "#f09a90",
        drawerTitleText: "#e8fff1",
        drawerSubtitleText: "#b9d7c8",

        listRowBorder: "#5e8a73",
        listRowTop: "#2a4738",
        listRowBottom: "#223b2f",
        listRowText: "#e8fff1"
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
        sliderHandleBottomPressed: "#5f86d0",

        previewSurfaceBorder: "#667285",
        previewSurfaceTop: "#303846",
        previewSurfaceBottom: "#2a313e",
        previewBadgeBorder: "#99b1d7",
        previewBadgeTop: "#516076",
        previewBadgeBottom: "#465467",
        previewBadgeText: "#edf2fb",
        previewHintText: "#a9b3c4",
        previewIndicatorActive: "#8db8ff",
        previewIndicatorInactive: "#5a6372",
        previewErrorText: "#ff9eac",
        previewFullscreenOverlay: "#cc12151b",
        previewFullscreenHint: "#f3f7ff",

        mainBgTop: "#1b2028",
        mainBgMid: "#242a34",
        mainBgBottom: "#2a313d",
        mainBlobTopRight: "#334d5d78",
        mainBlobBottomLeft: "#2f4f6f96",

        headerTop: "#303845",
        headerBottom: "#252d39",
        headerBorder: "#687488",

        menuButtonBorder: "#8b98ad",
        menuButtonBorderDown: "#a8b8d0",
        menuButtonTop: "#5a667b",
        menuButtonTopDown: "#4d586a",
        menuButtonBottom: "#4e596b",
        menuButtonBottomDown: "#434d5d",

        titleText: "#edf2fb",

        statusRunningTop: "#4d75c0",
        statusRunningBottom: "#3f63a6",
        statusRunningBorder: "#9fc0ff",
        statusIdleTop: "#4b5568",
        statusIdleBottom: "#3f4859",
        statusIdleBorder: "#8e9aaf",
        statusText: "#f3f7ff",

        drawerTop: "#2b3340",
        drawerBottom: "#232b36",
        drawerBorder: "#616d82",
        drawerOverlay: "#b10f1218",

        textPrimary: "#f3f7ff",
        textSecondary: "#b5bed0",
        textError: "#ff9eac",
        drawerTitleText: "#edf2fb",
        drawerSubtitleText: "#bcc5d7",

        listRowBorder: "#6a7588",
        listRowTop: "#384353",
        listRowBottom: "#303949",
        listRowText: "#eef2fa"
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
