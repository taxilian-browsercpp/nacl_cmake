# Written to work with cmake 2.6
cmake_minimum_required (VERSION 2.6)
set (CMAKE_BACKWARDS_COMPATIBILITY 2.6)

project(GciPNacl)

set(WITH_SYSTEM_BOOST 1)

set(Boost_INCLUDE_DIRS ${BOOST_ROOT})
set(Boost_LIBRARY_DIR ${BOOST_ROOT}/stage/lib)

message("Using boost include dir: ${BOOST_ROOT}")

file (GLOB GENERAL RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    [^.]*.cpp
    [^.]*.cc
    [^.]*.h
    [^.]*.mm
    [^.]*.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/../common/[^.]*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../common/[^.]*.h
    )

set (BUILD_SHARED_LIBS NO)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../GCIP ${CMAKE_CURRENT_BINARY_DIR}/GCIP)

# Generated files are stored in ${GENERATED} by the project configuration
SET_SOURCE_FILES_PROPERTIES(
    ${GENERATED}
    PROPERTIES
        GENERATED 1
    )

SOURCE_GROUP(Generated FILES
    ${GENERATED}
    )

SET( SOURCES
    ${GENERAL}
    ${GCIP}
    ${GENERATED}
    )

message("Using boost from ${Boost_INCLUDE_DIRS}")

include_directories(
    ${Boost_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}/../common
    #${PLUGIN_INCLUDE_DIRS}
    #${FBLIB_INCLUDE_DIRS}
    .
    ..
    )

if (NOT GCVERSION)
    set(GCVERSION '2.0.0.0')
endif()
add_definitions(-DGCPLUGIN_VERSION=\"${GCVERSION}\")

message("pNACL plugin version: ${GCVERSION}")

add_executable(${PROJECT_NAME} ${SOURCES})
set_target_properties(${PROJECT_NAME} PROPERTIES
    SUFFIX .pexe
    )

target_link_libraries(${PROJECT_NAME}
    ppapi_cpp ppapi pthread GCIP
    )

pnacl_finalise(${PROJECT_NAME})

# This will include Win/projectDef.cmake, Linux/projectDef.cmake, etc
#include_platform()
#ADD_PRECOMPILED_HEADER(${PROJECT_NAME} "${CMAKE_CURRENT_SOURCE_DIR}/precompiled_headers.h" "${CMAKE_CURRENT_SOURCE_DIR}/precompiled_headers.cpp" SOURCES)
    
#target_link_libraries(${PROJECT_NAME} GCIP)

