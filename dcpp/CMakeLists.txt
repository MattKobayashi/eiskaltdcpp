cmake_minimum_required(VERSION 3.31)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "4.0")
    cmake_policy(VERSION 3.31)          # lock behaviour for CMake ≥ 4
endif()
project (dcpp)

aux_source_directory(${PROJECT_SOURCE_DIR} dcpp_srcs)
file (GLOB dcpp_hdrs ${PROJECT_SOURCE_DIR}/*.h)

list (REMOVE_ITEM dcpp_srcs ${PROJECT_SOURCE_DIR}/FileReader.cpp)
list (REMOVE_ITEM dcpp_hdrs ${PROJECT_SOURCE_DIR}/FileReader.h)

set (DCPP_SRCS ${dcpp_srcs} PARENT_SCOPE)
set (DCPP_HDRS ${dcpp_hdrs} PARENT_SCOPE)

if (NOT LUA_SCRIPT)
    list (REMOVE_ITEM dcpp_srcs ${PROJECT_SOURCE_DIR}/ScriptManager.cpp)
endif (NOT LUA_SCRIPT)

include_directories (${PROJECT_BINARY_DIR}
                     ${BZIP2_INCLUDE_DIR}
                     ${ZLIB_INCLUDE_DIR}
                     ${OPENSSL_INCLUDE_DIR}
                     ${GETTEXT_INCLUDE_DIR}
                     ${LUA_INCLUDE_DIR}
                     ${IDN2_INCLUDE_DIR})

if (WIN32)
    set (LINK STATIC)
    set (WIN32_LIBS "unistring" "ws2_32")
else (WIN32)
    if (HAIKU)
        set (LINK STATIC)
        set (PTHREADS "root")
        set (HAIKU_LIBS "network" "textencoding")
    else (HAIKU)
        set (PTHREADS "pthread")
        if (APPLE)
            set (LINK STATIC)
        elseif (BUILD_STATIC)
            set (LINK STATIC)
        endif(APPLE)
    endif(HAIKU)
endif (WIN32)

if (NOT LINK)
    set (LINK SHARED)
endif (NOT LINK)

if (APPLE)
    set (APPLE_LIBS "iconv")
endif (APPLE)

set (UPNP "extra")

add_library (dcpp ${LINK} ${dcpp_srcs})

if (WITH_DHT)
    set (DHT_LIB "dht")
endif (WITH_DHT)

if (GETTEXT_FOUND)
    # Using GNU gettext does not guarantee that GNU libintl will be used. This
    # assumption breaks the build when using musl libc (which does implement
    # libintl, but does so without using internal GNU symbols).
    check_cxx_source_compiles("
        extern \"C\" int _nl_msg_cat_cntr;
        int main(void) {
            ++_nl_msg_cat_cntr;
            return 0;
        }"
        HAVE_NL_MSG_CAT_CNTR)
    set_property(SOURCE ${PROJECT_SOURCE_DIR}/Util.h
                 PROPERTY COMPILE_DEFINITIONS HAVE_NL_MSG_CAT_CNTR APPEND)
    set_property(SOURCE ${PROJECT_SOURCE_DIR}/Util.cpp
                 PROPERTY COMPILE_DEFINITIONS HAVE_NL_MSG_CAT_CNTR APPEND)
    if (NOT HAVE_NL_MSG_CAT_CNTR)
        message (STATUS "Build without GNU libintl library")
    endif ()
endif (GETTEXT_FOUND)

if (PERL_REGEX)
    set_property(SOURCE ${PROJECT_SOURCE_DIR}/ADLSearch.cpp
                 PROPERTY COMPILE_DEFINITIONS USE_PCRE )
    set(PCRE ${PCRE2_LIBRARIES})
endif (PERL_REGEX)

if (USE_IDN2)
    set_property(SOURCE ${PROJECT_SOURCE_DIR}/Util.cpp
                 PROPERTY COMPILE_DEFINITIONS USE_IDN2 APPEND)
endif(USE_IDN2)

if (XATTR_FOUND)
    set_property(SOURCE ${PROJECT_SOURCE_DIR}/HashManager.h
                 PROPERTY COMPILE_DEFINITIONS USE_XATTR APPEND)
    set_property(SOURCE ${PROJECT_SOURCE_DIR}/HashManager.cpp
                 PROPERTY COMPILE_DEFINITIONS USE_XATTR APPEND)
endif (XATTR_FOUND)

if (USE_MINIUPNP)
    set_property(SOURCE ${PROJECT_SOURCE_DIR}/DCPlusPlus.cpp
                        ${PROJECT_SOURCE_DIR}/MappingManager.cpp
                 PROPERTY COMPILE_DEFINITIONS USE_MINIUPNP )
endif()

if (ICONV_SECOND_ARGUMENT_IS_CONST)
    set_property(SOURCE ${PROJECT_SOURCE_DIR}/Text.cpp
                 PROPERTY COMPILE_DEFINITIONS ICONV_CONST=const)
endif (ICONV_SECOND_ARGUMENT_IS_CONST)

if (FORCE_XDG)
    set_property(SOURCE ${PROJECT_SOURCE_DIR}/Util.cpp
                 PROPERTY COMPILE_DEFINITIONS FORCE_XDG APPEND)
endif (FORCE_XDG)

if (HAVE_IFADDRS_H)
    set_property(SOURCE ${PROJECT_SOURCE_DIR}/Util.cpp
                 PROPERTY COMPILE_DEFINITIONS HAVE_IFADDRS_H APPEND)
endif (HAVE_IFADDRS_H)

if (WIN32 OR CYGWIN)
    set_property(TARGET dcpp PROPERTY COMPILE_FLAGS)
else ()
    set_property(TARGET dcpp PROPERTY COMPILE_FLAGS -fPIC)
endif ()

target_link_libraries (dcpp
                       ${DHT_LIB}
                       ${PTHREADS}
                       ${IDN2_LIBRARIES}
                       ${BZIP2_LIBRARIES}
                       ${ZLIB_LIBRARIES}
                       ${OPENSSL_LIBRARIES}
                       ${GETTEXT_LIBRARIES}
                       ${ICONV_LIBRARIES}
                       ${WIN32_LIBS}
                       ${APPLE_LIBS}
                       ${HAIKU_LIBS}
                       ${LUA_LIBRARIES}
                       ${UPNP}
                       ${PCRE}
                       ${XATTR_LIBRARIES})
set_target_properties(dcpp PROPERTIES
                      VERSION ${SO_VERSION}
                      SOVERSION ${SO_VERSION}
                      OUTPUT_NAME "eiskaltdcpp")

if (APPLE)
    set (LIBDIR ${PROJECT_NAME_GLOBAL}.app/Contents/Frameworks)
    set_target_properties(dcpp PROPERTIES BUILD_WITH_INSTALL_RPATH 1
                          INSTALL_NAME_DIR "@executable_path/../Frameworks")
endif(APPLE)

if (LINK STREQUAL SHARED)
    if (WITH_DEV_FILES)
        install (TARGETS dcpp LIBRARY DESTINATION ${LIBDIR})
    else (WITH_DEV_FILES)
        install (TARGETS dcpp LIBRARY DESTINATION ${LIBDIR} NAMELINK_SKIP)
    endif (WITH_DEV_FILES)
    message (STATUS "Build libeiskaltdcpp as shared library")
elseif (LINK STREQUAL STATIC AND WITH_DEV_FILES)
    install (TARGETS dcpp LIBRARY DESTINATION ${LIBDIR})
    message (STATUS "Build libeiskaltdcpp as static library")
endif (LINK STREQUAL SHARED)

if (WITH_DEV_FILES)
    if (NOT EISKALTDCPP_INCLUDE_DIR)
        set (EISKALTDCPP_INCLUDE_DIR "${CMAKE_INSTALL_PREFIX}/include/eiskaltdcpp")
    endif (NOT EISKALTDCPP_INCLUDE_DIR)
    message (STATUS "Headers of libeiskaltdcpp will be installed to: ${EISKALTDCPP_INCLUDE_DIR}")
    install (FILES ${dcpp_hdrs} DESTINATION ${EISKALTDCPP_INCLUDE_DIR}/dcpp/)

    set (prefix ${CMAKE_INSTALL_PREFIX})
    set (libdir ${LIBDIR})
    set (includedir ${EISKALTDCPP_INCLUDE_DIR})
    configure_file (${CMAKE_SOURCE_DIR}/eiskaltdcpp.pc.in ${CMAKE_BINARY_DIR}/eiskaltdcpp.pc @ONLY)
    install (FILES ${CMAKE_BINARY_DIR}/eiskaltdcpp.pc
             DESTINATION ${CMAKE_INSTALL_PREFIX}/${LIBDIR}/pkgconfig)
endif (WITH_DEV_FILES)

foreach(LANG ${LANGUAGES})
    install(FILES ${dcpp_BINARY_DIR}/${LANG}_libeiskaltdcpp.mo
            DESTINATION ${LOCALE_DIR}/${LANG}/LC_MESSAGES
            RENAME libeiskaltdcpp.mo)
endforeach(LANG ${LANGUAGES})
