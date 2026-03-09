QT       += core gui network concurrent

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

INCLUDEPATH += \
    src/util \
    src

SOURCES += \
    src/image_service.cpp \
    src/inference_client.cpp \
    src/main.cpp \
    src/mainwindow.cpp \
    src/mainwindow_images.cpp \
    src/mainwindow_inference.cpp \
    src/mainwindow_preset.cpp \
    src/mainwindow_ui.cpp \
    src/mainwindow_utils.cpp \
    src/preset_storage.cpp \
    src/util/aspectratiopixmaplabel.cpp \
    src/util/globalsetting.cpp \
    src/util/filedialog.cpp \
    src/settings_mapper.cpp

HEADERS += \
    src/image_service.h \
    src/inference_client.h \
    src/inference_types.h \
    src/mainwindow.h \
    src/mainwindow_utils.h \
    src/preset_storage.h \
    src/util/aspectratiopixmaplabel.h \
    src/util/globalsetting.h \
    src/util/filedialog.h \
    src/settings_mapper.h

FORMS += \
    src/util/filedialog.ui \
    src/mainwindow.ui

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
