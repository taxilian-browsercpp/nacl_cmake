#!/bin/bash

#GEN='Xcode'
GEN='Unix Makefiles'
BUILDDIR=nacl_build
ARCH=-DCMAKE_OSX_ARCHITECTURES="nacl"

NACL_PLATFORM=$(find nacl_sdk -type d -name '*_pnacl' | grep toolchain)
NACL_TOOLCHAIN=${NACL_PLATFORM##*/toolchain/}
NACL_ROOT=${NACL_PLATFORM%%toolchain/*}
pushd $NACL_ROOT
export NACL_ROOT=`pwd`
popd > /dev/null
BOOST_ROOT_FILE=$(find naclports -name project-config.jam | grep boost)
BOOST_ROOT=${BOOST_ROOT_FILE%/*}
pushd $BOOST_ROOT
BOOST_ROOT=`pwd`
popd > /dev/null
mkdir -p "$BUILDDIR"
pushd "$BUILDDIR"
cmake -G "$GEN" -DCMAKE_BUILD_TYPE=Release -DBOOST_ROOT=$BOOST_ROOT -DNACL_ROOT=${NACL_ROOT} -DNACL_TOOLCHAIN=${NACL_TOOLCHAIN} -DCMAKE_TOOLCHAIN_FILE=pnacl.toolchain.cmake ${ARCH} "$@" ../src
if [ "$?" -ne 0 ]; then
    echo "CMake failed. Please check error messages"
    popd > /dev/null
    exit 1
else
    popd
fi


