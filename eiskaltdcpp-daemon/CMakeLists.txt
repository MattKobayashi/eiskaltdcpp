cmake_minimum_required(VERSION 3.31)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "4.0")
    cmake_policy(VERSION 3.31)          # lock behaviour for CMake ≥ 4
endif()
project(eiskaltdcpp-daemon)
# ######### General setup ##########
include_directories(${PROJECT_SOURCE_DIR}
                    ${PROJECT_SOURCE_DIR}/..
                    ${GETTEXT_INCLUDE_DIR})

aux_source_directory(${PROJECT_SOURCE_DIR} nasdc_SRCS)

if (JSONRPC_DAEMON AND XMLRPC_DAEMON)
    message("   Build both JSONRPC and XMLRPC interfaces is prohibited for now, set XMLRPC_DAEMON=OFF")
    set (XMLRPC_DAEMON OFF CACHE BOOL "Make daemon as xmlrpc server" FORCE)
endif (JSONRPC_DAEMON AND XMLRPC_DAEMON)

if (JSONRPC_DAEMON)
    message (STATUS "Build daemon with JSONRPC interface")
    set(JSONRPCLIBS jsonrpc-cpp)
    add_definitions (-DJSONRPC_DAEMON)
    include_directories(${JSONCPP_INCLUDE_DIR})
    if (LOCAL_JSONCPP)
        include_directories(${PROJECT_SOURCE_DIR}/../json/jsoncpp)
    else(LOCAL_JSONCPP)
        include_directories(${JSONCPP_INCLUDE_DIR})
        set(JSONRPCLIBS ${JSONCPP_LIBRARY} ${JSONRPCLIBS})
    endif (LOCAL_JSONCPP)
else (JSONRPC_DAEMON)
    list (REMOVE_ITEM nasdc_SRCS ${PROJECT_SOURCE_DIR}/jsonrpcmethods.cpp)
endif (JSONRPC_DAEMON)

if (XMLRPC_DAEMON)
    message (STATUS "Build daemon with XMLRPC interface")
    if (NOT NO_UI_DAEMON)
        set (NO_UI_DAEMON 1 CACHE BOOL "Daemon without anyone ui" FORCE)
    endif (NOT NO_UI_DAEMON)
    set (xmlrpclibs "abyss-server")
    find_package (XMLRPC REQUIRED c++2 ${xmlrpclibs})
    include_directories(${XMLRPC_INCLUDE_DIRS})
    set (XMLRPCLIBS ${XMLRPC_LIBRARIES})
    add_definitions (-DXMLRPC_DAEMON )
endif (XMLRPC_DAEMON)

if (HAVE_DAEMON)
    add_definitions(-DHAVE_DAEMON)
endif(HAVE_DAEMON)

if (WIN32)
    if (OPENSSL_MSVC)
        list (APPEND nasdc_SRCS ../windows/applink.c)
    endif (OPENSSL_MSVC)
endif (WIN32)

if (LUA_SCRIPT)
  include_directories (${LUA_INCLUDE_DIR})
endif (LUA_SCRIPT)

if (ENABLE_STACKTRACE)
    set_property(SOURCE ${PROJECT_SOURCE_DIR}/src/nasdc.cpp PROPERTY COMPILE_DEFINITIONS ENABLE_STACKTRACE)
endif (ENABLE_STACKTRACE)

# actual target:
add_executable (${PROJECT_NAME} MACOSX_BUNDLE WIN32
                ${nasdc_SRCS}
                )

list(APPEND LIBS
        ${XMLRPCLIBS}
        ${JSONRPCLIBS}
        ${ICONV_LIBRARIES}
        )

if (BUILD_STATIC)
    if (UNIX AND NOT APPLE AND NOT HAIKU)
        list (APPEND LIBS -lssl -lcrypto -lm -ldl)
    endif (UNIX AND NOT APPLE AND NOT HAIKU)
endif (BUILD_STATIC)

target_link_libraries (${PROJECT_NAME} extra dcpp ${LIBS})

if (DEBUG_DAEMON)
    add_definitions(-D_DEBUG_DAEMON)
    message (STATUS "Enabled debug output from eiskaltdcpp-daemon!")
endif()

install (TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION ${BINDIR}
    BUNDLE DESTINATION ${BUNDLEDIR})

if (UNIX AND NOT APPLE AND NOT HAIKU)
    if(COMPRESS_MANPAGES)
        execute_process (
                    OUTPUT_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.1.gz
                    COMMAND "${GZIP_CMD}" -9
                    INPUT_FILE ${PROJECT_NAME}.1
                    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/)
        install (FILES ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.1.gz DESTINATION ${MAN_DIR})
    else(COMPRESS_MANPAGES)
        install (FILES ${PROJECT_NAME}.1 DESTINATION ${MAN_DIR})
    endif(COMPRESS_MANPAGES)
endif ()

if (WIN32 OR APPLE)
    install (FILES manual.${PROJECT_NAME}.html DESTINATION "${CLIENT_DOCS_DIR}")
endif ()

if (INSTALL_METAINFO)
    install (FILES ${PROJECT_NAME}.appdata.xml DESTINATION ${SHARE_DIR}/metainfo)
endif ()

