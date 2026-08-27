#!/bin/bash

set -Eeuo pipefail
trap 'printf "\033[31mbuild fail: command=%s, line=%s, status=%s\033[0m\n" \
    "${BASH_COMMAND}" "${LINENO}" "$?"' ERR

# linux x86_64; arm linux arm
export TARGET_OS="${TARGET_OS:-arm}"

TOP_PATH=$(pwd)
export OUT_PATH=${TOP_PATH}/out
RELEASE_PATH=${OUT_PATH}/release

mkdir -p "${OUT_PATH}"
exec > >(tee "${OUT_PATH}/build.log") 2>&1

function aibuild_libevdev()
{
    pushd ./external/libevdev
    ./autogen.sh
    ./configure --host=arm-none-linux-gnueabihf CC=arm-none-linux-gnueabihf-gcc --prefix="${OUT_PATH}/_install"
    make -j4 && make install
    popd

}

function aibuild_arm_lvgl()
{
    export PKG_CONFIG_PATH=${OUT_PATH}/_install/lib/pkgconfig:${PKG_CONFIG_PATH:-}
    cmake -B "${OUT_PATH}/build" -GNinja -DCMAKE_TOOLCHAIN_FILE=./cmake/user_cross_compile_setup.cmake \
        -DCMAKE_INSTALL_PREFIX="${OUT_PATH}/lvgl_lib"

    cmake --build "${OUT_PATH}/build"
    cmake --install "${OUT_PATH}/build"

    if [ -d ${RELEASE_PATH} ];then
		rm -rf ${RELEASE_PATH}
	fi
    mkdir -p ${RELEASE_PATH}
    cp -af ${OUT_PATH}/build/bin/lvglsim ${RELEASE_PATH}/
    cp -af ${OUT_PATH}/_install ${RELEASE_PATH}/
}

function aibuild_linuxpc_lvgl()
{
    cmake -B "${OUT_PATH}/build" -GNinja
    cmake --build "${OUT_PATH}/build"
}

if [[ "${TARGET_OS}" == "arm" ]];then
	echo build linux arm...
	aibuild_libevdev
	aibuild_arm_lvgl

elif [[ "${TARGET_OS}" == "x86_64" ]];then
	echo build linux x86_64...
	aibuild_linuxpc_lvgl

else
	echo do nothing
fi

printf "\033[32mbuild successfully\033[0m\n"
