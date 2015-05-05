#!/bin/bash
PROJECT_PATH="$( cd "$( dirname "$0" )" && pwd )"
pushd $PROJECT_PATH

function run_or_fail {
    echo "Testing $@"
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "Command failed: $@ run in $(pwd)" 1>&2
        exit $status
    fi
    return $status
}
function abspath {
    pushd $1 > /dev/null
    local dirname=$(pwd)
    popd > /dev/null
    echo $dirname
}

NACL_PATH=$PROJECT_PATH/nacl_sdk

if [ -z "$NACL_VERSION" ] ; then
    NACL_VERSION=42
fi

if [ ! -d "$NACL_PATH" ] ; then
    curl http://storage.googleapis.com/nativeclient-mirror/nacl/nacl_sdk/nacl_sdk.zip -o nacl_sdk.zip
    unzip nacl_sdk.zip
fi

if [ ! -x "$NACL_CLANG" ] ; then
    # pnacl sdk not found; install it
    echo " -- Updating NACL sdk if needed to pepper_$NACL_VERSION"
    pushd nacl_sdk > /dev/null
    run_or_fail ./naclsdk install pepper_$NACL_VERSION
    SDK_COUNT=$(ls . | grep ^pepper_ | wc -l)
    if [ $SDK_COUNT -ne 1 ] ; then
        echo " -- ! More than one version of the nacl sdk installed; fixing"
        rm -Rf pepper_*
        run_or_fail ./naclsdk install pepper_$NACL_VERSION
    fi
    popd > /dev/null
fi

NACL_PLATFORM=$(find nacl_sdk -type d -name '*_pnacl' | grep toolchain)
export NACL_SDK_ROOT=$(abspath ${NACL_PLATFORM%%toolchain/*})

CMAKE_CMD=`which cmake`
if [ ! -x "$CMAKE_CMD" ] ; then
    echo " !! CMake not installed! Please install cmake!"
    exit 1;
fi

popd > /dev/null
