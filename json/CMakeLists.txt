cmake_minimum_required(VERSION 3.31)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "4.0")
    cmake_policy(VERSION 3.31)          # lock behaviour for CMake ≥ 4
endif()
project (jsonrpcpp)

# ######### General setup ##########

include_directories (${PROJECT_SOURCE_DIR})

aux_source_directory (${PROJECT_SOURCE_DIR}/jsonrpc-cpp jsonrpcpp_SRCS)
file (GLOB client_staff ${PROJECT_SOURCE_DIR}/jsonrpc-cpp/*client*)
list (REMOVE_ITEM jsonrpcpp_SRCS ${client_staff})
list (REMOVE_ITEM jsonrpcpp_SRCS ${PROJECT_SOURCE_DIR}/jsonrpc-cpp/jsonrpc_udpserver.cpp
                                 ${PROJECT_SOURCE_DIR}/jsonrpc-cpp/jsonrpc_tcpserver.cpp
                                 ${PROJECT_SOURCE_DIR}/jsonrpc-cpp/jsonrpc_server.cpp
                                 ${PROJECT_SOURCE_DIR}/jsonrpc-cpp/networking.cpp)
set_source_files_properties (${PROJECT_SOURCE_DIR}/jsonrpc-cpp/mongoose.c PROPERTIES COMPILE_FLAGS "-DNDEBUG -DNO_CGI -DNO_SSL")

if (LOCAL_JSONCPP)
    set (JSONCPP_LIBRARY jsoncpp)
    set (JSONCPP_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/jsoncpp/)
    aux_source_directory (${PROJECT_SOURCE_DIR}/jsoncpp/src jsoncpp_SRCS)
    add_library (jsoncpp STATIC ${jsoncpp_SRCS})
    message (STATUS "Building with embedded jsoncpp library")
else (LOCAL_JSONCPP)
    find_package (JsonCpp)
    message (STATUS "Building with system jsoncpp library")
endif (LOCAL_JSONCPP)

if (DEBUG_MONGOOSE)
    add_definitions (-DNS_ENABLE_DEBUG)
    message (STATUS "Enabled debug output of mongoose library!")
endif (DEBUG_MONGOOSE)

include_directories (${JSONCPP_INCLUDE_DIR})

add_library (jsonrpc-cpp STATIC ${jsonrpcpp_SRCS})
target_link_libraries (jsonrpc-cpp ${JSONCPP_LIBRARY})

