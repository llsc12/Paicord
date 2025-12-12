cmake_minimum_required(VERSION 3.16)

project(Paicord VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CXXQT_QTCOMPONENTS Widgets Core Gui Quick Qml QuickControls2 QuickWidgets Xml Svg QuickPrivate)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)



set(QMAKE "${QT_QMAKE_EXECUTABLE}")
set(qmake_path "${QT_QMAKE_EXECUTABLE}")

find_package(CxxQt QUIET)
if(NOT CxxQt_FOUND)
    include(FetchContent)
    FetchContent_Declare(
        CxxQt
        GIT_REPOSITORY https://github.com/kdab/cxx-qt-cmake.git
        GIT_TAG main
    )

    FetchContent_MakeAvailable(CxxQt)
endif()

find_package(Qt6 COMPONENTS ${CXXQT_QTCOMPONENTS})
set(Qt "Qt6")

qt_standard_project_setup(REQUIRES 6.10)

set(CRATE paicord)

cxx_qt_import_crate(
    MANIFEST_PATH rust/Cargo.toml
    CRATES ${CRATE}
    QT_MODULES Qt::Core Qt::Gui Qt::Qml Qt::QuickControls2 Qt::Quick Qt::Widgets Qt::QuickWidgets Qt::Svg Qt::Xml
    QMAKE ${qmake_path})

cxx_qt_import_qml_module(${CRATE}_qml
    URI "paicord.rs"
    SOURCE_CRATE ${CRATE})

qt_add_executable(appPaicord
    cpp/main.cpp
)

target_link_libraries(appPaicord
    PRIVATE
    ${CRATE}_qml
    Qt6::Quick Qt::Core Qt::Gui Qt::Qml Qt::QuickControls2 Qt::Widgets Qt::QuickWidgets Qt::Svg Qt::Xml
)

qt_import_qml_plugins(${CRATE})

set_target_properties(appPaicord PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    AUTOMOC TRUE
)

target_link_libraries(appPaicord
    PRIVATE Qt6::Quick Qt::Core Qt::Gui Qt::Qml Qt::QuickControls2 Qt::Widgets Qt::QuickWidgets Qt::Svg Qt::Xml
)
