#!/bin/sh

# Authors: Boris Pek
# License: Public Domain
# Created: 2018-08-21
# Updated: 2022-04-05
# Version: N/A
#
# Description: script for building of app bundles for macOS
# Currently it is used for testing builds on Travis CI and for producing
# official builds of program which are hosted on SourceForge.
#
# Build dependencies and useful tools:
# export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=1
# brew install ccache coreutils cmake
# brew install aspell jsoncpp libidn2 lua miniupnpc qt@5
#
# Additional tools:
# brew install wget htop

set -e

if [ -z "${HOMEBREW}" ]; then
    case "$(uname -m)" in
        arm64)  HOMEBREW="/opt/homebrew" ;;   # default Apple Silicon prefix
        *)      HOMEBREW="/usr/local"   ;;    # default Intel prefix
    esac
fi

PATH="${HOMEBREW}/bin:${PATH}"
PATH="${HOMEBREW}/opt/ccache/libexec:${PATH}"
CUR_DIR="$(dirname $(realpath ${0}))"
MAIN_DIR="$(realpath ${CUR_DIR}/..)"
TOOLCHAIN_FILE="${CUR_DIR}/homebrew-toolchain.cmake"

BUILD_OPTIONS="-DCMAKE_BUILD_TYPE=Release \
               -DUSE_QT=OFF \
               -DUSE_QT5=ON \
               -DUSE_QT_SQLITE=ON \
               -DUSE_MINIUPNP=ON \
               -DUSE_ASPELL=ON \
               -DUSE_PROGRESS_BARS=OFF \
               -DNO_UI_DAEMON=OFF \
               -DJSONRPC_DAEMON=OFF \
               -DPERL_REGEX=ON \
               -DLUA_SCRIPT=ON \
               -DWITH_SOUNDS=ON \
               -DWITH_LUASCRIPTS=ON \
               -DLOCAL_ASPELL_DATA=OFF \
               -DLOCAL_JSONCPP=OFF"
# Force the native architecture when building on Apple Silicon
[ "$(uname -m)" = "arm64" ] && BUILD_OPTIONS="${BUILD_OPTIONS} -DCMAKE_OSX_ARCHITECTURES=arm64"

mkdir -p "${MAIN_DIR}/builddir"
cd "${MAIN_DIR}/builddir"

which nproc > /dev/null && JOBS=$(nproc) || JOBS=4

cmake .. -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" ${BUILD_OPTIONS} ${@}
cmake --build . --target all -- -j ${JOBS}

cpack -G DragNDrop
cp -a EiskaltDC++*.dmg "${MAIN_DIR}/../"

echo
echo "App bundle is built successfully! See:"
echo "$(realpath ${MAIN_DIR}/..)/$(ls EiskaltDC++*.dmg | sort -V | tail -n1)"
echo
