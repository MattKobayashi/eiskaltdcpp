cmake_minimum_required(VERSION 3.31)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "4.0")
    cmake_policy(VERSION 3.31)          # lock behaviour for CMake ≥ 4
endif()
project(eiskaltdcpp-cli)

if (USE_CLI_XMLRPC)
    install (FILES cli-xmlrpc.pl DESTINATION ${BINDIR} RENAME ${PROJECT_NAME}-xmlrpc
        PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

    install (FILES cli-xmlrpc-config.pl DESTINATION ${CLIENT_DATA_DIR}/cli
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)

    if (UNIX)
        if(COMPRESS_MANPAGES)
            execute_process (
                    OUTPUT_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}-xmlrpc.1.gz
                    COMMAND "${GZIP_CMD}" -9
                    INPUT_FILE ${PROJECT_NAME}-xmlrpc.1
                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/)
            install (FILES ${PROJECT_BINARY_DIR}/${PROJECT_NAME}-xmlrpc.1.gz DESTINATION ${MAN_DIR})
        else(COMPRESS_MANPAGES)
            install (FILES ${PROJECT_NAME}-xmlrpc.1 DESTINATION ${MAN_DIR})
        endif(COMPRESS_MANPAGES)
    endif (UNIX)
endif ()

if (USE_CLI_JSONRPC)
    install (FILES cli-jsonrpc.pl DESTINATION ${BINDIR} RENAME ${PROJECT_NAME}-jsonrpc
        PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

    install (FILES cli-jsonrpc-config.pl DESTINATION ${CLIENT_DATA_DIR}/cli
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)

    if (UNIX)
        if(COMPRESS_MANPAGES)
            execute_process (
                    OUTPUT_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}-jsonrpc.1.gz
                    COMMAND "${GZIP_CMD}" -9
                    INPUT_FILE ${PROJECT_NAME}-jsonrpc.1
                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/)
            install (FILES ${PROJECT_BINARY_DIR}/${PROJECT_NAME}-jsonrpc.1.gz DESTINATION ${MAN_DIR})
        else(COMPRESS_MANPAGES)
            install (FILES ${PROJECT_NAME}-jsonrpc.1 DESTINATION ${MAN_DIR})
        endif(COMPRESS_MANPAGES)
    endif (UNIX)
endif ()

