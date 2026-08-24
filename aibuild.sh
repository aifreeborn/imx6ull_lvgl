#!/bin/bash

set -Eeuo pipefail
trap 'printf "\033[31mbuild fail\033[0m\n"' ERR

export TOP_PATH=$(pwd)
export OUT_PATH=${TOP_PATH}/out
RELEASE_PATH=${OUT_PATH}/release

if [ -d ${OUT_PATH} ];then
    rm -rf ${OUT_PATH}
fi

pushd ./external/libevdev
./autogen.sh
./configure --host=arm-none-linux-gnueabihf CC=arm-none-linux-gnueabihf-gcc --prefix="${OUT_PATH}/_install"
make -j4 && make install
popd


export PKG_CONFIG_PATH=${OUT_PATH}/_install/lib/pkgconfig:${PKG_CONFIG_PATH:-}
cmake -B "${OUT_PATH}/build" -GNinja -DCMAKE_TOOLCHAIN_FILE=./cmake/user_cross_compile_setup.cmake \
	-DCMAKE_INSTALL_PREFIX="${OUT_PATH}/lvgl_lib"

cmake --build "${OUT_PATH}/build"
cmake --install "${OUT_PATH}/build"


mkdir ${RELEASE_PATH}
cp -af ${OUT_PATH}/build/bin/lvglsim ${RELEASE_PATH}/
cp -af ${OUT_PATH}/_install ${RELEASE_PATH}/

printf "\033[32mbuild successfully\033[0m\n"
