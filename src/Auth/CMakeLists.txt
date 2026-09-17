find_package(Qt6 REQUIRED COMPONENTS Core Quick)

qt_add_library(AuthModule STATIC
    AuthController.cc
    AuthController.h
)

qt_add_qml_module(AuthModule
    URI             QGroundControl.Auth
    VERSION         1.0
    RESOURCE_PREFIX /qml
    QML_FILES
        LoginPage.qml
        RegisterPage.qml
    IMPORTS
        QtQuick
        QtQuick.Controls
        QtQuick.Layouts
    NO_PLUGIN
)

target_link_libraries(AuthModule
    PRIVATE Qt6::Quick
    PUBLIC  Qt6::Core
)

target_include_directories(AuthModule PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
