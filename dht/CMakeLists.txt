cmake_minimum_required(VERSION 3.31)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "4.0")
    cmake_policy(VERSION 3.31)          # lock behaviour for CMake ≥ 4
endif()
project (dht)

aux_source_directory(${PROJECT_SOURCE_DIR} dht_srcs)

set (DHT_SRCS ${dht_srcs} PARENT_SCOPE)

include_directories (${PROJECT_BINARY_DIR}
                     ${OPENSSL_INCLUDE_DIR}
                     ${GETTEXT_INCLUDE_DIR}
                     ${BZIP2_INCLUDE_DIR}
                     ${ZLIB_INCLUDE_DIR}
                     ${LUA_INCLUDE_DIR})

set (LINK STATIC)

add_library (dht ${LINK} ${dht_srcs})

if (WIN32 OR CYGWIN)
    set_property(TARGET dht PROPERTY COMPILE_FLAGS)
else ()
    set_property(TARGET dht PROPERTY COMPILE_FLAGS -fPIC)
endif ()

