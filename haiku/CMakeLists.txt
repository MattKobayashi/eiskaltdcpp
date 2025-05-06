cmake_minimum_required(VERSION 3.31)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "4.0")
    cmake_policy(VERSION 3.31)          # lock behaviour for CMake ≥ 4
endif()
project(haiku)

if (HAIKU_PKG)
    install (CODE "
        EXECUTE_PROCESS (
            COMMAND rc -o \"${PROJECT_BINARY_DIR}/haiku.rsrc\"
                          \"${PROJECT_SOURCE_DIR}/haiku.rdef\"
            COMMAND xres -o \"${PROJECT_BINARY_DIR}/eiskaltdcpp-qt/eiskaltdcpp-qt\"
                            \"${PROJECT_BINARY_DIR}/haiku.rsrc\"  )")
endif ()
