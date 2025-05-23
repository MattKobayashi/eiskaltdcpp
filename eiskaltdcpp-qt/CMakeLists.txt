cmake_minimum_required(VERSION 3.31)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "4.0")
    cmake_policy(VERSION 3.31)          # lock behaviour for CMake ≥ 4
endif()
project (eiskaltdcpp-qt)

include_directories(${PROJECT_BINARY_DIR})

if (USE_QT)
    find_package (Qt4 4.7.0 COMPONENTS QtCore QtGui QtXml QtNetwork REQUIRED)
elseif (USE_QT5)
    find_package (Qt5Core          5.0.2 REQUIRED)
    find_package (Qt5Gui           5.0.2 REQUIRED)
    find_package (Qt5Widgets       5.0.2 REQUIRED)
    find_package (Qt5Xml           5.0.2 REQUIRED)
    find_package (Qt5Network       5.0.2 REQUIRED)
    # This is temporary workaround which fixes build with Qt5 on Travis CI:
    find_package (Qt5LinguistTools       REQUIRED)
    find_package (Qt5Multimedia    5.0.2 REQUIRED)
    find_package (Qt5Concurrent    5.0.2 REQUIRED)
endif ()

set (QT_USE_QTNETWORK 1)
set (QT_USE_QTXML 1)
set (QT_USE_QTWEBKIT 0)

if (USE_QT_QML)
    if (USE_QT)
        find_package (Qt4 4.7.0 COMPONENTS QtDeclarative REQUIRED)
    elseif (USE_QT5)
        find_package (Qt5Declarative 5.0.2 REQUIRED)
        find_package (Qt5XmlPatterns 5.0.2 REQUIRED)
    endif ()
    add_definitions(-DUSE_QML)
    set (QT_USE_QTDECLARATIVE 1)
    set (USE_JS ON)
    message (STATUS "Building with Qt Declarative UI support")
else (USE_QT_QML)
    message (STATUS "Building without Qt Declarative UI support")
endif (USE_QT_QML)

if (APPLE OR HAIKU)
    set (DBUS_NOTIFY OFF)
endif ()

if (DBUS_NOTIFY)
    if (USE_QT)
        find_package (Qt4 4.6.0 COMPONENTS QtDBus REQUIRED)
    elseif (USE_QT5)
        find_package (Qt5DBus 5.0.2 REQUIRED)
    endif (USE_QT)
    add_definitions (-DDBUS_NOTIFY)
    set (QT_USE_QTDBUS 1)
    message (STATUS "Building with Qt DBus support")
else (DBUS_NOTIFY)
    message (STATUS "Building without Qt DBus support")
endif (DBUS_NOTIFY)

if (USE_JS)
    if (USE_QT)
        find_package (Qt4 4.6.0 COMPONENTS QtScript REQUIRED)
    elseif (USE_QT5)
        find_package (Qt5Script 5.0.2 REQUIRED)
    endif ()
    add_definitions (-DUSE_JS)
    set (QT_USE_QTSCRIPT 1)
    message (STATUS "Building with Qt Script support")
else (USE_JS)
    message (STATUS "Building without Qt Script support")
endif (USE_JS)

if (USE_QT_SQLITE)
    if (USE_QT)
        find_package (Qt4 4.6.0 COMPONENTS QtSql REQUIRED)
    elseif (USE_QT5)
        find_package (Qt5Sql 5.0.2 REQUIRED)
    endif (USE_QT)
    add_definitions (-DUSE_QT_SQLITE)
    set (QT_USE_QTSQL 1)
    message (STATUS "Building with Qt SQLite support")
else (USE_QT_SQLITE)
    message (STATUS "Building without Qt SQLite support")
endif (USE_QT_SQLITE)

aux_source_directory(${PROJECT_SOURCE_DIR}/src SRCS)

if (NOT HAIKU)
    list (APPEND SRCS src/qtsingleapp/qtsinglecoreapplication.cpp)
endif (NOT HAIKU)

file (GLOB MOC_HDRS ${PROJECT_SOURCE_DIR}/src/*.h)

if (NOT HAIKU AND NOT APPLE)
    list (APPEND MOC_HDRS
                src/qtsingleapp/qtsinglecoreapplication.h)
    list (REMOVE_ITEM MOC_HDRS
                ${PROJECT_SOURCE_DIR}/src/EiskaltApp_haiku.h)
    list (REMOVE_ITEM MOC_HDRS
                ${PROJECT_SOURCE_DIR}/src/EiskaltApp_mac.h)
elseif (HAIKU)
    list (REMOVE_ITEM MOC_HDRS
                ${PROJECT_SOURCE_DIR}/src/EiskaltApp.h)
    list (REMOVE_ITEM MOC_HDRS
                ${PROJECT_SOURCE_DIR}/src/EiskaltApp_mac.h)
elseif (APPLE)
    list (APPEND MOC_HDRS
                src/qtsingleapp/qtsinglecoreapplication.h)
    list (REMOVE_ITEM MOC_HDRS
                ${PROJECT_SOURCE_DIR}/src/EiskaltApp.h)
    list (REMOVE_ITEM MOC_HDRS
                ${PROJECT_SOURCE_DIR}/src/EiskaltApp_haiku.h)
endif (NOT HAIKU AND NOT APPLE)

file (GLOB UI_FORMS ${PROJECT_SOURCE_DIR}/ui/*.ui)

set (WIN_RESOURCES)
if (MINGW AND WIN32)
    add_custom_command (OUTPUT "${PROJECT_BINARY_DIR}/eiskaltdcpp-qt_rc.o"
                        COMMAND ${CMAKE_RC_COMPILER}
                                -I"${PROJECT_SOURCE_DIR}/"
                                -i "${PROJECT_SOURCE_DIR}/eiskaltdcpp-qt.rc"
                                -o "${PROJECT_BINARY_DIR}/eiskaltdcpp-qt_rc.o")
    set (WIN_RESOURCES ${PROJECT_BINARY_DIR}/eiskaltdcpp-qt_rc.o)
elseif (NOT MINGW AND WIN32)
    set (WIN_RESOURCES"${PROJECT_SOURCE_DIR}/eiskaltdcpp-qt.rc")
endif (MINGW AND WIN32)

if (NOT USE_ASPELL)
    message (STATUS "Building without Aspell support")
    set (LOCAL_ASPELL_DATA OFF)
elseif (USE_ASPELL)
    find_package (ASPELL REQUIRED)
    message (STATUS "Building with Aspell support")
endif (NOT USE_ASPELL)

if (NOT ASPELL_FOUND)
    list (REMOVE_ITEM SRCS ${PROJECT_SOURCE_DIR}/src/SpellCheck.cpp)
    list (REMOVE_ITEM MOC_HDRS ${PROJECT_SOURCE_DIR}/src/SpellCheck.h)
endif (NOT ASPELL_FOUND)

if (USE_JS)
    file (GLOB scriptengine_srcs ${PROJECT_SOURCE_DIR}/scriptengine/*.cpp)
    file (GLOB scriptengine_hdrs ${PROJECT_SOURCE_DIR}/scriptengine/*.h)
    list (APPEND SRCS
            ${scriptengine_srcs}
            src/codeeditor/codeeditor.cpp)
    list (APPEND MOC_HDRS
            ${scriptengine_hdrs}
            src/codeeditor/codeeditor.h)
endif (USE_JS)

if (NOT USE_JS)
    list (REMOVE_ITEM UI_FORMS
            ${PROJECT_SOURCE_DIR}/ui/UIScriptManager.ui
            ${PROJECT_SOURCE_DIR}/ui/UIDialogScriptConsole.ui)
    list (REMOVE_ITEM SRCS
            ${PROJECT_SOURCE_DIR}/src/ScriptManagerDialog.cpp)
    list (REMOVE_ITEM MOC_HDRS
            ${PROJECT_SOURCE_DIR}/src/ScriptManagerDialog.h)
endif (NOT USE_JS)

if (USE_QT)
    #Create moc files
    QT4_WRAP_CPP (M_SRCS ${MOC_HDRS} OPTIONS -nn)
    #Create .h files from ui files
    QT4_WRAP_UI (U_SRCS ${UI_FORMS})
elseif (USE_QT5)
    #Create moc files
    QT5_WRAP_CPP (M_SRCS ${MOC_HDRS} OPTIONS -nn)
    #Create .h files from ui files
    QT5_WRAP_UI (U_SRCS ${UI_FORMS})
endif()

if (USE_QT5 AND NOT USE_QT)
    set (QT_LRELEASE_EXECUTABLE ${Qt5_LRELEASE_EXECUTABLE})
    get_target_property(QT_RCC_EXECUTABLE Qt5::rcc LOCATION)
endif()

#Create translations
file (MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/translations/)
foreach (LANGUAGE ${LANGUAGES})
        set (TS ${PROJECT_SOURCE_DIR}/translations/${LANGUAGE}.ts)
        set (QM ${PROJECT_BINARY_DIR}/translations/${LANGUAGE}.qm)
        list (APPEND TRANSLATIONS ${TS})
        list (APPEND TRANSLATIONS_BINARY ${QM})
        add_custom_command (OUTPUT "${QM}"
                            DEPENDS "${TS}"
                            COMMAND ${QT_LRELEASE_EXECUTABLE}
                            ARGS "${TS}" -qm "${QM}")
endforeach ()

if (WIN32 OR APPLE OR INSTALL_QT_TRANSLATIONS OR BUILD_STATIC)
    # Qt translations
    get_target_property (QtCore_location Qt5::Core LOCATION)
    get_filename_component (QtCore_DIR "${QtCore_location}" PATH)
    if (WIN32)
        set (QT_ROOT_DIR "${QtCore_DIR}/..")
    elseif (APPLE)
        set (QT_ROOT_DIR "${QtCore_DIR}/../..")
    elseif (BUILD_STATIC)
        set (QT_ROOT_DIR "${QtCore_DIR}/..")
    elseif (INSTALL_QT_TRANSLATIONS AND NOT BUILD_STATIC)
        set (QT_ROOT_DIR "/usr/share/qt5")
    endif ()
    set (QT_TRANSLATIONS_DIR "${QT_ROOT_DIR}/translations/")
    file (GLOB QT_TRANSLATIONS "${QT_TRANSLATIONS_DIR}/qt_*.qm")
    foreach (FILE ${QT_TRANSLATIONS})
        if (NOT FILE MATCHES "_help_")
            list (APPEND TRANSLATIONS_BINARY ${FILE})
        endif ()
    endforeach ()
    file (GLOB QT_TRANSLATIONS "${QT_TRANSLATIONS_DIR}/qtbase_*.qm")
    list (APPEND TRANSLATIONS_BINARY ${QT_TRANSLATIONS})
endif ()

add_custom_target(${PROJECT_NAME}_tr ALL DEPENDS ${TRANSLATIONS_BINARY})

set (DEFAULT_QRC_FILE ${PROJECT_SOURCE_DIR}/icons/appl/default/default.qrc)

if (UNIX AND NOT APPLE AND NOT HAIKU)
    if(COMPRESS_MANPAGES)
        execute_process (OUTPUT_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.1.gz
                         COMMAND "${GZIP_CMD}" -9
                         INPUT_FILE ${PROJECT_NAME}.1
                         WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/)
        install (FILES ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.1.gz DESTINATION ${MAN_DIR})
    else(COMPRESS_MANPAGES)
        install (FILES ${PROJECT_NAME}.1 DESTINATION ${MAN_DIR})
    endif(COMPRESS_MANPAGES)
endif ()

if (WIN32 OR APPLE)
    install (FILES manual.${PROJECT_NAME}.html DESTINATION "${CLIENT_DOCS_DIR}" RENAME manual.${PROJECT_NAME_GLOBAL}.html)
endif ()

execute_process (COMMAND ${QT_RCC_EXECUTABLE} -binary  ${DEFAULT_QRC_FILE}
                                              -o ${PROJECT_BINARY_DIR}/default.rcc
                 WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/)

if (USE_QT)
    include (${QT_USE_FILE})
    include_directories (${QT_INCLUDES})
    list (APPEND LIBS ${QT_LIBRARIES})
elseif (USE_QT5)
    include_directories (${Qt5Core_INCLUDE_DIRS}
                         ${Qt5Gui_INCLUDE_DIRS}
                         ${Qt5Widgets_INCLUDE_DIRS}
                         ${Qt5Xml_INCLUDE_DIRS}
                         ${Qt5Multimedia_INCLUDE_DIRS}
                         ${Qt5Concurrent_INCLUDE_DIRS}
                         ${Qt5Declarative_INCLUDE_DIRS}
                         ${Qt5XmlPatterns_INCLUDE_DIRS}
                         ${Qt5DBus_INCLUDE_DIRS}
                         ${Qt5Script_INCLUDE_DIRS}
                         ${Qt5Sql_INCLUDE_DIRS}
                         ${Qt5Network_INCLUDE_DIRS})
    list (APPEND LIBS ${Qt5Core_LIBRARIES}
                      ${Qt5Gui_LIBRARIES}
                      ${Qt5Widgets_LIBRARIES}
                      ${Qt5Xml_LIBRARIES}
                      ${Qt5Multimedia_LIBRARIES}
                      ${Qt5Concurrent_LIBRARIES}
                      ${Qt5Declarative_LIBRARIES}
                      ${Qt5XmlPatterns_LIBRARIES}
                      ${Qt5DBus_LIBRARIES}
                      ${Qt5Script_LIBRARIES}
                      ${Qt5Sql_LIBRARIES}
                      ${Qt5Network_LIBRARIES})
endif ()

include_directories (${PROJECT_SOURCE_DIR}
                     ${PROJECT_SOURCE_DIR}/src
                     ${PROJECT_SOURCE_DIR}/scriptengine
                     ${PROJECT_SOURCE_DIR}/..
                     ${GETTEXT_INCLUDE_DIR})
list (APPEND LIBS ${ICONV_LIBRARIES})

if (BUILD_STATIC AND USE_QT5)
    if (WIN32)
        find_library (QT5FontDatabaseSupport Qt5FontDatabaseSupport)
        find_library (QT5EventDispatcherSupport Qt5EventDispatcherSupport)
        find_library (QT5ThemeSupport Qt5ThemeSupport)
        find_library (QT5AccessibilitySupport Qt5AccessibilitySupport)
        find_library (QT5WindowsUIAutomationSupport Qt5WindowsUIAutomationSupport)
        list (INSERT LIBS 0 Qt5::QWindowsVistaStylePlugin)
        if (DBUS_NOTIFY)
            list (APPEND LIBS Qt5::DBus -ldbus-1)
        endif (DBUS_NOTIFY)
        list (APPEND LIBS Qt5::QWindowsIntegrationPlugin
                          ${QT5FontDatabaseSupport}
                          ${QT5EventDispatcherSupport}
                          ${QT5ThemeSupport}
                          ${QT5AccessibilitySupport}
                          ${QT5WindowsUIAutomationSupport}
                          Qt5::QSQLiteDriverPlugin
                          Qt5::Sql
                          Qt5::QWindowsAudioPlugin
                          Qt5::Multimedia
                          ${PCRE2_LIBRARIES}
                          -lharfbuzz
                          -lwinmm
                          -limm32
                          -lsqlite3
                          -ljpeg
                          -lpng
                          -lopengl32
                          -lwtsapi32
                          -lwinmm
                          -lcrypt32
                          -lstrmiids
                          -lfreetype
             )
    elseif (UNIX AND NOT APPLE AND NOT HAIKU)
        add_definitions (-DSQLITE_ENABLE_COLUMN_METADATA=1)
        find_library (QT5FontDatabaseSupport Qt5FontDatabaseSupport)
        find_library (QT5EventDispatcherSupport Qt5EventDispatcherSupport)
        find_library (QT5ThemeSupport Qt5ThemeSupport)
        find_library (QT5ServiceSupport Qt5ServiceSupport)
        find_library (QT5AccessibilitySupport Qt5AccessibilitySupport)
        find_library (QT5EdidSupport Qt5EdidSupport)
        find_library (QT5XcbQpa Qt5XcbQpa)
        find_library (XcbStatic xcb-static)
        if (DBUS_NOTIFY)
            set (QT5DBus Qt5::DBus)
        else (DBUS_NOTIFY)
            set (QT5DBus "")
        endif (DBUS_NOTIFY)
        list (APPEND LIBS Qt5::QXcbIntegrationPlugin
                          ${QT5XcbQpa}
                          ${QT5FontDatabaseSupport}
                          ${QT5EventDispatcherSupport}
                          ${QT5ThemeSupport}
                          ${QT5ServiceSupport}
                          ${QT5AccessibilitySupport}
                          ${QT5EdidSupport}
                          Qt5::QSQLiteDriverPlugin
                          Qt5::Sql
                          Qt5::Multimedia
                          ${QT5DBus}
                          ${XcbStatic}
                          ${PCRE2_LIBRARIES}
                          -lsqlite3
                          -ljpeg
                          -lpng
                          -lfontconfig
                          -lfreetype
                          -luuid
                          -lexpat
                          -lSM
                          -lICE
                          -lGL
                          -lm
                          -ldl
                          -ldrm
                          -lxkbcommon
                          -lxkbcommon-x11
                          -lXdamage
                          -lXfixes
                          -lX11-xcb
                          -lxcb-glx
                          -lxcb-dri2
                          -lXxf86vm
                          -lXext
                          -lX11
                          -lxcb
                          -lXau
                          -lXdmcp
             )
    endif (WIN32)
endif (BUILD_STATIC AND USE_QT5)

if (WIN32)
    if (OPENSSL_MSVC)
        list (APPEND SRCS ../windows/applink.c)
    endif (OPENSSL_MSVC)
endif (WIN32)

if (APPLE)
    find_library (COCOA_LIBRARY Cocoa)
    list (APPEND LIBS ${COCOA_LIBRARY})
endif (APPLE)

if (USE_PROGRESS_BARS)
    add_definitions (-DUSE_PROGRESS_BARS)
endif (USE_PROGRESS_BARS)

if (FREE_SPACE_BAR_C)
    add_definitions (-DFREE_SPACE_BAR_C)
endif (FREE_SPACE_BAR_C)

if (USE_ASPELL)
    include_directories (${ASPELL_INCLUDE_DIR})
    list (APPEND LIBS ${ASPELL_LIBRARIES})
    add_definitions (-DUSE_ASPELL ${ASPELL_DEFINITIONS})
    if (LOCAL_ASPELL_DATA)
        add_definitions (-DLOCAL_ASPELL_DATA)
    endif (LOCAL_ASPELL_DATA)
endif (USE_ASPELL)

if (LUA_SCRIPT)
    include_directories (${LUA_INCLUDE_DIR})
    list (APPEND LIBS ${LUA_LIBRARIES})
endif (LUA_SCRIPT)

if (USE_MINIUPNP)
    set_property(SOURCE ${PROJECT_SOURCE_DIR}/src/SettingsConnection.cpp
                 PROPERTY COMPILE_DEFINITIONS USE_MINIUPNP )
endif()

if (FORCE_XDG)
   set_property(SOURCE ${PROJECT_SOURCE_DIR}/src/main.cpp
                PROPERTY COMPILE_DEFINITIONS FORCE_XDG )
endif (FORCE_XDG)

if (HAVE_IFADDRS_H)
  set_property(SOURCE ${PROJECT_SOURCE_DIR}/src/WulforUtil.cpp
               PROPERTY COMPILE_DEFINITIONS HAVE_IFADDRS_H APPEND)
endif (HAVE_IFADDRS_H)

if (ENABLE_STACKTRACE)
    set_property(SOURCE ${PROJECT_SOURCE_DIR}/src/main.cpp
                 PROPERTY COMPILE_DEFINITIONS ENABLE_STACKTRACE)
endif (ENABLE_STACKTRACE)

if (APPLE)
    set (MACOSICON "${PROJECT_SOURCE_DIR}/../data/icons/icon_1024x1024.icns")
    set (MACOSICONINBUNDLE "icon_1024x1024.icns")
    # Set how it shows up in the Info.plist file
    set (MACOSX_BUNDLE_ICON_FILE ${MACOSICONINBUNDLE})
    # Set where in the bundle to put the icns file
    set_source_files_properties(${MACOSICON} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
    # Include the icns file in the target
    list (APPEND SRCS ${MACOSICON})
endif (APPLE)

add_executable (${PROJECT_NAME} MACOSX_BUNDLE WIN32 src/main.cpp
                ${M_SRCS}
                ${U_SRCS}
                ${SRCS}
                ${HDRS}
                ${MOC_HDRS}
                ${TRANSLATIONS}
                ${WIN_RESOURCES}
                translations)

add_definitions (-DCLIENT_DATA_DIR="${CLIENT_DATA_DIR}")
add_definitions (-DCLIENT_SOUNDS_DIR="${CLIENT_SOUNDS_DEST}")
add_definitions (-DCLIENT_TRANSLATIONS_DIR="${CLIENT_TRANSLATIONS_DEST}")

if (DEBUG_QT_UI)
    add_definitions (-D_DEBUG_QT_UI)
    message (STATUS "Enabled debug output from eiskaltdcpp-qt!")
endif (DEBUG_QT_UI)
if (DEBUG_IPFILTER)
    add_definitions (-D_DEBUG_IPFILTER)
endif (DEBUG_IPFILTER)

if (USE_JS)
    if (UNIX AND NOT APPLE AND NOT HAIKU)
        set (CLIENT_SCRIPTS_DEST "${CLIENT_DATA_DIR}/qt/qtscripts")
    else ()
        set (CLIENT_SCRIPTS_DEST "${CLIENT_DATA_DIR}/qtscripts")
    endif ()
    add_definitions (-DCLIENT_SCRIPTS_DIR="${CLIENT_SCRIPTS_DEST}")
endif (USE_JS)

if (WIN32)
    add_definitions (-DCLIENT_ICONS_DIR="${CLIENT_DATA_DIR}/icons")
    add_definitions (-DCLIENT_RES_DIR="${CLIENT_DATA_DIR}/client-res")
elseif (HAIKU)
    add_definitions (-DCLIENT_ICONS_DIR="icons")
    add_definitions (-DCLIENT_RES_DIR="client-res")
elseif (APPLE)
    add_definitions (-DCLIENT_ICONS_DIR="icons")
    add_definitions (-DCLIENT_RES_DIR="client-res")
else ()
    add_definitions (-DCLIENT_ICONS_DIR="${CLIENT_DATA_DIR}/qt/icons")
    add_definitions (-DCLIENT_RES_DIR="${CLIENT_DATA_DIR}/qt/client-res")
endif ()

if (APPLE)
    target_link_libraries (${PROJECT_NAME} ${LIBS} extra dcpp iconv)
elseif (HAIKU)
    target_link_libraries (${PROJECT_NAME} ${LIBS} extra dcpp be)
else (APPLE)
    target_link_libraries (${PROJECT_NAME} ${LIBS} extra dcpp)
endif (APPLE)

if (WIN32 OR APPLE OR HAIKU)
    set_property (TARGET ${PROJECT_NAME} PROPERTY OUTPUT_NAME "${PROJECT_NAME_GLOBAL}")
else ()
    set_property (TARGET ${PROJECT_NAME} PROPERTY OUTPUT_NAME "${PROJECT_NAME}")
endif ()

install (TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION ${BINDIR}
    BUNDLE DESTINATION ${BUNDLEDIR})

if (APPLE)
    set (plugin_dest_dir ${PROJECT_NAME_GLOBAL}.app/Contents/MacOS)
    set (qtconf_dest_dir ${PROJECT_NAME_GLOBAL}.app/Contents/Resources)
    set (APPS "\${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME_GLOBAL}.app")
    set (DIRS "\${QT_LIBRARY_DIRS}" "\${PC_UPNP_LIBRARY_DIRS}" "\${CMAKE_INSTALL_PREFIX}/${LIBDIR}")
    set (CPACK_PACKAGE_ICON ${MACOSICON})
    set (CPACK_BUNDLE_ICON ${MACOSICON})
    set (CPACK_BUNDLE_NAME ${PROJECT_NAME_GLOBAL})
    if (CMAKE_OSX_DEPLOYMENT_TARGET)
        string (REGEX REPLACE "^(.*-.*)-g.*$" "\\1-macOS${CMAKE_OSX_DEPLOYMENT_TARGET}" FILE_NAME_VERSION "${APP_VERSION}")
        set (CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME_GLOBAL}-${FILE_NAME_VERSION}-${CMAKE_SYSTEM_PROCESSOR}")
    else (CMAKE_OSX_DEPLOYMENT_TARGET)
        set (CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME_GLOBAL}-${APP_VERSION}-${CMAKE_SYSTEM_PROCESSOR}")
    endif (CMAKE_OSX_DEPLOYMENT_TARGET)
    set_target_properties (${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${PROJECT_SOURCE_DIR}/Info.plist.in)
    set (MACOSX_BUNDLE_GUI_IDENTIFIER "com.github.eiskaltdcpp")
    set (MACOSX_BUNDLE_LONG_VERSION_STRING ${PROJECT_NAME_GLOBAL} ${APP_VERSION})
    set (MACOSX_BUNDLE_BUNDLE_NAME ${PROJECT_NAME_GLOBAL})
    set (MACOSX_BUNDLE_SHORT_VERSION_STRING ${APP_VERSION})
    set (MACOSX_BUNDLE_BUNDLE_VERSION ${APP_VERSION})
    set (MACOSX_BUNDLE_COPYRIGHT "Copyright 2009-2021 EiskaltDC++ developers")
endif (APPLE)

if (USE_JS)
    install (DIRECTORY qtscripts/ DESTINATION ${CLIENT_SCRIPTS_DEST}
             PATTERN "*.sh"
             PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
             PATTERN "*.php"
             PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
endif (USE_JS)

install (FILES ${TRANSLATIONS_BINARY} DESTINATION ${CLIENT_TRANSLATIONS_DEST})

if (UNIX AND NOT APPLE AND NOT HAIKU)
    install (DIRECTORY icons/appl icons/user DESTINATION "${CLIENT_DATA_DIR}/qt/icons")
    install (FILES ${PROJECT_BINARY_DIR}/default.rcc DESTINATION "${CLIENT_DATA_DIR}/qt/client-res")
else ()
    install (DIRECTORY icons/appl icons/user DESTINATION "${CLIENT_DATA_DIR}/icons")
    install (FILES ${PROJECT_BINARY_DIR}/default.rcc DESTINATION "${CLIENT_DATA_DIR}/client-res")
endif ()

if (UNIX AND NOT APPLE AND NOT HAIKU)
    install (FILES ${PROJECT_NAME}.desktop DESTINATION ${SHARE_DIR}/applications)
endif ()

if (INSTALL_METAINFO)
    install (FILES ${PROJECT_NAME}.appdata.xml DESTINATION ${SHARE_DIR}/metainfo)
endif ()

if (APPLE)
    if (USE_QT)
        install (DIRECTORY ${QT_LIBRARY_DIR}/QtGui.framework/Resources/qt_menu.nib
                 DESTINATION ${PROJECT_NAME_GLOBAL}.app/Contents/Resources)

        install (CODE "
                    file(WRITE \"\${CMAKE_INSTALL_PREFIX}/${qtconf_dest_dir}/qt.conf\" \"\")")

        install (CODE "
                    file(GLOB_RECURSE QTPLUGINS
                        \"\${CMAKE_INSTALL_PREFIX}/${plugin_dest_dir}/plugins/*${CMAKE_SHARED_LIBRARY_SUFFIX}\")
                    include(BundleUtilities)
                    fixup_bundle(\"${APPS}\" \"\${QTPLUGINS}\" \"${DIRS}\")")
    elseif (USE_QT5)
        if (${_qt5Core_install_prefix} STREQUAL "")
        message(WARNING "Warning! \"_qt5Core_install_prefix\" is not set, macdeployqt found in PATH will be used")
        set (MACDEPLOYQT "macdeployqt")
        else (${_qt5Core_install_prefix} STREQUAL "")
        set (MACDEPLOYQT "${_qt5Core_install_prefix}/bin/macdeployqt")
        endif (${_qt5Core_install_prefix} STREQUAL "")
        install (CODE "
                    execute_process(COMMAND ${MACDEPLOYQT} ${PROJECT_NAME_GLOBAL}.app -verbose=2
                        WORKING_DIRECTORY \${CMAKE_INSTALL_PREFIX})")
    endif (USE_QT)
    set (CPACK_BINARY_DRAGNDROP ON)
endif (APPLE)

include(CPack)
