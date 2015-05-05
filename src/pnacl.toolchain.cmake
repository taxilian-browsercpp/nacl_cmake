include( CMakeForceCompiler )

set( NACL                       ON )
set( PCH_DISABLE                ON )

set( PLATFORM_EMBEDDED          ON )
set( PLATFORM_NAME              "PNaCl" )
set( PLATFORM_TRIPLET           "pnacl" )
set( PLATFORM_PREFIX            "${NACL_ROOT}/toolchain/${NACL_TOOLCHAIN}" )
set( PLATFORM_PORTS_PREFIX      "${NACL_ROOT}/ports/lib/newlib_pnacl" )
set( PLATFORM_EXE_SUFFIX        ".pexe" )

set( CMAKE_SYSTEM_NAME          "Linux" CACHE STRING "Target system." )
set( CMAKE_SYSTEM_PROCESSOR     "LLVM-IR" CACHE STRING "Target processor." )
set( CMAKE_FIND_ROOT_PATH       "${PLATFORM_PORTS_PREFIX};${PLATFORM_PREFIX}/usr" )
set( CMAKE_AR                   "${PLATFORM_PREFIX}/bin/${PLATFORM_TRIPLET}-ar" CACHE STRING "")
set( CMAKE_RANLIB               "${PLATFORM_PREFIX}/bin/${PLATFORM_TRIPLET}-ranlib" CACHE STRING "")
set( CMAKE_C_COMPILER           "${PLATFORM_PREFIX}/bin/${PLATFORM_TRIPLET}-clang" )
set( CMAKE_CXX_COMPILER         "${PLATFORM_PREFIX}/bin/${PLATFORM_TRIPLET}-clang++" )
set( CMAKE_C_FLAGS              "-Wall -Wno-unused-variable -U__STRICT_ANSI__" CACHE STRING "" )
set( CMAKE_CXX_FLAGS            "-Wall -Wno-unused-variable -U__STRICT_ANSI__" CACHE STRING "" )
set( CMAKE_C_FLAGS_RELEASE      "-Wall -Wno-unused-variable -O4 -ftree-vectorize -ffast-math" CACHE STRING "" )
set( CMAKE_CXX_FLAGS_RELEASE    "-Wall -Wno-unused-variable -O4 -ftree-vectorize -ffast-math" CACHE STRING "" )

cmake_force_c_compiler(         ${CMAKE_C_COMPILER} Clang )
cmake_force_cxx_compiler(       ${CMAKE_CXX_COMPILER} Clang )

set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY )

macro( pnacl_finalise _target )
    # Run finalize to prepare the .pexe
    add_custom_command( TARGET ${_target}
        POST_BUILD COMMAND "${PLATFORM_PREFIX}/bin/${PLATFORM_TRIPLET}-finalize"
        "$<TARGET_FILE:${_target}>" )

    # Run create_nmf to make the nmf for it
    add_custom_command( TARGET ${_target}
        POST_BUILD COMMAND 
            "${NACL_ROOT}/tools/create_nmf.py"
            -o "${CMAKE_CURRENT_BINARY_DIR}/${_target}.nmf"
            -s "${CMAKE_CURRENT_BINARY_DIR}"
            "$<TARGET_FILE:${_target}>" )
endmacro()

include_directories( SYSTEM ${NACL_ROOT}/include )
include_directories( SYSTEM ${NACL_ROOT}/include/newlib )
include_directories( SYSTEM ${NACL_ROOT}/ports/include )
link_directories( ${NACL_ROOT}/lib/pnacl/${CMAKE_BUILD_TYPE} )
