QT += core gui network concurrent

CONFIG += c++17

INCLUDEPATH += \
    src \
    src/util

SOURCES += \
    src/image_service.cpp \
    src/inference_client.cpp \
    src/main.cpp \
    src/mainwindow_utils.cpp \
    src/preset_storage.cpp \
    src/util/globalsetting.cpp

HEADERS += \
    src/image_service.h \
    src/inference_client.h \
    src/inference_types.h \
    src/mainwindow_utils.h \
    src/preset_storage.h \
    src/util/globalsetting.h

mobile {
    QT += qml quick quickcontrols2 quickdialogs2

    DEFINES += DREAMMACHINE_MOBILE_UI

    SOURCES += \
        src/mobile_view_model.cpp

    HEADERS += \
        src/mobile_view_model.h

    RESOURCES += \
        qml.qrc
} else {
    QT += widgets
    QT += qml quick quickcontrols2 quickdialogs2

    # Desktop keeps QWidget as default, pass --qml at runtime to preview QML UI.
    DEFINES += DREAMMACHINE_ENABLE_QML_PREVIEW

    SOURCES += \
        src/mobile_view_model.cpp \
        src/mainwindow.cpp \
        src/mainwindow_images.cpp \
        src/mainwindow_inference.cpp \
        src/mainwindow_preset.cpp \
        src/mainwindow_ui.cpp \
        src/settings_mapper.cpp \
        src/util/aspectratiopixmaplabel.cpp \
        src/util/filedialog.cpp

    HEADERS += \
        src/mobile_view_model.h \
        src/mainwindow.h \
        src/settings_mapper.h \
        src/util/aspectratiopixmaplabel.h \
        src/util/filedialog.h

    RESOURCES += \
        qml.qrc

    FORMS += \
        src/mainwindow.ui \
        src/util/filedialog.ui
}
