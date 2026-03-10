cmake_minimum_required(VERSION 3.16)
project(DreamMachine VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

# Match qmake "mobile { ... } else { ... }" behavior.
option(DREAMMACHINE_FORCE_MOBILE_BRANCH "Force qmake-like mobile source set on non-mobile hosts" OFF)
set(DREAMMACHINE_IS_MOBILE FALSE)
if(DREAMMACHINE_FORCE_MOBILE_BRANCH OR ANDROID OR IOS OR CMAKE_SYSTEM_NAME STREQUAL "Android" OR CMAKE_SYSTEM_NAME STREQUAL "iOS")
    set(DREAMMACHINE_IS_MOBILE TRUE)
endif()

set(DREAMMACHINE_QT_COMPONENTS
    Core
    Gui
    Network
    Concurrent
    Qml
    Quick
    QuickControls2
    QuickDialogs2
)
if(NOT DREAMMACHINE_IS_MOBILE)
    list(APPEND DREAMMACHINE_QT_COMPONENTS Widgets)
endif()

find_package(Qt6 6.5 REQUIRED COMPONENTS ${DREAMMACHINE_QT_COMPONENTS})

qt_standard_project_setup(REQUIRES 6.5)

set(DREAMMACHINE_COMMON_SOURCES
    src/main.cpp
    src/image_service.cpp
    src/inference_client.cpp
    src/mainwindow_utils.cpp
    src/preset_storage.cpp
    src/util/globalsetting.cpp
)

set(DREAMMACHINE_COMMON_HEADERS
    src/image_service.h
    src/inference_client.h
    src/inference_types.h
    src/mainwindow_utils.h
    src/preset_storage.h
    src/util/globalsetting.h
)

set(DREAMMACHINE_MOBILE_SOURCES
    src/mobile_view_model.cpp
)

set(DREAMMACHINE_MOBILE_HEADERS
    src/mobile_view_model.h
)

set(DREAMMACHINE_DESKTOP_SOURCES
    src/mobile_view_model.cpp
    src/mainwindow.cpp
    src/mainwindow_images.cpp
    src/mainwindow_inference.cpp
    src/mainwindow_preset.cpp
    src/mainwindow_ui.cpp
    src/settings_mapper.cpp
    src/util/aspectratiopixmaplabel.cpp
    src/util/filedialog.cpp
    src/mainwindow.ui
    src/util/filedialog.ui
)

set(DREAMMACHINE_DESKTOP_HEADERS
    src/mobile_view_model.h
    src/mainwindow.h
    src/settings_mapper.h
    src/util/aspectratiopixmaplabel.h
    src/util/filedialog.h
)


set(DREAMMACHINE_TARGET_SOURCES
    ${DREAMMACHINE_COMMON_SOURCES}
    ${DREAMMACHINE_COMMON_HEADERS}
    qml.qrc
)

if(DREAMMACHINE_IS_MOBILE)
    list(APPEND DREAMMACHINE_TARGET_SOURCES
        ${DREAMMACHINE_MOBILE_SOURCES}
        ${DREAMMACHINE_MOBILE_HEADERS}
    )
else()
    list(APPEND DREAMMACHINE_TARGET_SOURCES
        ${DREAMMACHINE_DESKTOP_SOURCES}
        ${DREAMMACHINE_DESKTOP_HEADERS}
    )
endif()

qt_add_executable(${CMAKE_PROJECT_NAME}
    ${DREAMMACHINE_TARGET_SOURCES}
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    src
    src/util
)

if(DREAMMACHINE_IS_MOBILE)
    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE DREAMMACHINE_MOBILE_UI)
else()
    # Desktop keeps QWidget as default, pass --qml at runtime to preview QML UI.
    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE DREAMMACHINE_ENABLE_QML_PREVIEW)
endif()

target_link_libraries(${CMAKE_PROJECT_NAME}
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Network
        Qt6::Concurrent
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::QuickDialogs2
)

if(NOT DREAMMACHINE_IS_MOBILE)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE Qt6::Widgets)
endif()
## Android
if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        #QT_ANDROID_ABIS "armeabi-v7a;arm64-v8a;x86;x86_64"
        #QT_ANDROID_BUILD_ALL_ABIS TRUE
        QT_ANDROID_MIN_SDK_VERSION 23
        QT_ANDROID_TARGET_SDK_VERSION 35
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/platform/android/"
    )

    # Patched QtConnectivity
    #target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE QT_CONNECTIVITY_PATCHED)

    # Android background service
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE Qt::CorePrivate)
endif()

if(APPLE)
    set(CMAKE_XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.example.dreammachine.ios")
    set(CMAKE_XCODE_ATTRIBUTE_MARKETING_VERSION "${PROJECT_VERSION}")

    set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")
    set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "")
    set(CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "")
    set(CMAKE_XCODE_ATTRIBUTE_PROVISIONING_PROFILE "")
endif()

## macOS
if (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0")
endif()

## iOS
if (CMAKE_SYSTEM_NAME STREQUAL "iOS")
    #set(QT_DEFAULT_MEDIA_BACKEND "darwin")
    set(CMAKE_OSX_ARCHITECTURES "arm64")
    set(CMAKE_OSX_SYSROOT "iphoneos")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "14.0")
    set(CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "14.0")
    set(CMAKE_XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2") # iPhone,iPad
    set(CMAKE_XCODE_ATTRIBUTE_INFOPLIST_FILE "${CMAKE_CURRENT_SOURCE_DIR}/platform/ios/Info.plist")
    
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/platform/ios/Info.plist"
        # New Xcode attributes (???)
        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER           "com.example.rplayer"
        XCODE_ATTRIBUTE_PRODUCT_NAME                        ${CMAKE_PROJECT_NAME}
        XCODE_ATTRIBUTE_CURRENT_PROJECT_VERSION             ${CMAKE_PROJECT_VERSION}
        XCODE_ATTRIBUTE_MARKETING_VERSION                   ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET          "14.0"
        XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY              "1,2"   # iPhone,iPad
        XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME  "AppIcon"
        XCODE_ATTRIBUTE_GCC_GENERATE_DEBUGGING_SYMBOLS      "YES"
        XCODE_ATTRIBUTE_UIRequiresFullScreen                "YES"   # Add this line
    )

    qt_import_plugins(${CMAKE_PROJECT_NAME}
        INCLUDE Qt6::QIosOptionalPlugin_NSPhotoLibraryPlugin
    )
endif()

## Windows
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
endif()

## Release build? Set "no debug" macros
if (CMAKE_BUILD_TYPE STREQUAL Release)
    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE
        NDEBUG
        QT_NO_DEBUG
        QT_NO_DEBUG_OUTPUT
    )
endif()

include(GNUInstallDirs)

install(TARGETS DreamMachine
    BUNDLE  DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

