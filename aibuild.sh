#!/bin/bash

set -Eeuo pipefail
trap 'printf "\033[31mbuild fail: command=%s, line=%s, status=%s\033[0m\n" \
    "${BASH_COMMAND}" "${LINENO}" "$?"' ERR

# linux x86_64; arm linux arm
export TARGET_OS="${TARGET_OS:-arm}"

TOP_PATH=$(pwd)
export OUT_PATH=${TOP_PATH}/out_${TARGET_OS}
TEMP_PATH=${OUT_PATH}/tmp
TARGET_PATH=${OUT_PATH}/obj
BUILD_PATH=${OUT_PATH}/build
RELEASE_PATH=${OUT_PATH}/release
PACKAGE_PATH=${OUT_PATH}/imx6ull_pro-lvgl-linux-armhf.tar.gz
DEB_PACKAGE_PATH=${OUT_PATH}/imx6ull-pro-lvgl_1.0.0_armhf.deb

if [[ ! -d "${OUT_PATH}" ]];then
    mkdir -p "${OUT_PATH}"
fi

if [[ ! -d "${TARGET_PATH}" ]];then
    mkdir -p "${TARGET_PATH}"
fi
exec > >(tee "${OUT_PATH}/build.log") 2>&1

function aibuild_libevdev()
{
    tar -xvf ${TOP_PATH}/external/libevdev.tar.gz -C ${TARGET_PATH}
    pushd ${TARGET_PATH}/libevdev
    ./autogen.sh
    ./configure --host=arm-none-linux-gnueabihf CC=arm-none-linux-gnueabihf-gcc --prefix="${OUT_PATH}/_install_libevdev"
    make -j4 && make install
    popd
}

function aibuild_arm_lvgl()
{
    export PKG_CONFIG_PATH=${OUT_PATH}/_install_libevdev/lib/pkgconfig:${PKG_CONFIG_PATH:-}
    cmake -B "${BUILD_PATH}" -GNinja -DTARGET_OS=arm \
        -DCMAKE_TOOLCHAIN_FILE=./cmake/user_cross_compile_setup.cmake \
        -DCMAKE_INSTALL_PREFIX="${OUT_PATH}/lvgl_lib"

    cmake --build "${BUILD_PATH}"
    cmake --install "${BUILD_PATH}"
}

function make_prebuilt_lvgl_targets()
{
    if [ -d ${RELEASE_PATH} ];then
        rm -rf ${RELEASE_PATH}
    fi
    mkdir -p "${RELEASE_PATH}"
    mkdir -p "${RELEASE_PATH}/lib"

    cp -af "${BUILD_PATH}/bin/lvglsim" "${RELEASE_PATH}/"
    cp -af boards/imx6ull_pro/images "${RELEASE_PATH}/"
}

function make_linux_package()
{
    local arm_gcc_runtime
    arm_gcc_runtime=$(arm-none-linux-gnueabihf-gcc -print-file-name=libgcc_s.so.1)
    if [ ! -f "${arm_gcc_runtime}" ]; then
        printf "ARM runtime library not found: %s\n" "${arm_gcc_runtime}" >&2
        return 1
    fi
    cp -af "${arm_gcc_runtime}" "${RELEASE_PATH}/lib/libgcc_s.so.1"
    cp -af "${OUT_PATH}/_install_libevdev/lib/libevdev.so.2" \
        "${OUT_PATH}/_install_libevdev/lib/libevdev.so.2.3.0" "${RELEASE_PATH}/lib/"

    cp -af tools/imx6ull_pro/run.sh tools/imx6ull_pro/README.txt "${RELEASE_PATH}/"
    chmod 755 "${RELEASE_PATH}/run.sh"
    tar -czf "${PACKAGE_PATH}" -C "${RELEASE_PATH}" .

    printf "i.MX6ULL Linux package created: %s\n" "${PACKAGE_PATH}"
}

function make_deb_package()
{
    if [[ ! -d ${TEMP_PATH} ]];then
        mkdir -p "${TEMP_PATH}"
    fi

    local deb_root
    deb_root=$(mktemp -d "${TEMP_PATH:-/tmp}/imx6ull_pro-lvgl-deb.XXXXXX")
    mkdir -p "${deb_root}/DEBIAN" "${deb_root}/opt/imx6ull_pro-lvgl" "${deb_root}/usr/bin"
    cp -a "${RELEASE_PATH}/." "${deb_root}/opt/imx6ull_pro-lvgl/"
    cp -af tools/imx6ull_pro/control "${deb_root}/DEBIAN/control"
    cp -af tools/imx6ull_pro/imx6ull_pro-lvgl "${deb_root}/usr/bin/imx6ull_pro-lvgl"
    sed -i 's/\r$//' "${deb_root}/usr/bin/imx6ull_pro-lvgl"
    find "${deb_root}" -type d -exec chmod 755 {} +
    find "${deb_root}" -type f -exec chmod 644 {} +
    chmod 755 "${deb_root}/DEBIAN"
    chmod 755 "${deb_root}/opt/imx6ull_pro-lvgl/lvglsim" \
        "${deb_root}/opt/imx6ull_pro-lvgl/run.sh" \
        "${deb_root}/usr/bin/imx6ull_pro-lvgl"
    rm -f "${DEB_PACKAGE_PATH}"
    dpkg-deb --build --root-owner-group "${deb_root}" "${DEB_PACKAGE_PATH}"
    rm -rf "${deb_root}"

    printf "i.MX6ULL Debian package created: %s\n" "${DEB_PACKAGE_PATH}"
}

function aibuild_linuxpc_lvgl()
{
    cmake -B "${BUILD_PATH}" -GNinja -DTARGET_OS=x86_64
    cmake --build "${BUILD_PATH}"
}

if [[ "${TARGET_OS}" == "arm" ]];then
    echo build linux arm...
    aibuild_libevdev
    aibuild_arm_lvgl
    make_prebuilt_lvgl_targets
    make_linux_package
    make_deb_package

elif [[ "${TARGET_OS}" == "x86_64" ]];then
    echo build linux x86_64...
    aibuild_linuxpc_lvgl
    make_prebuilt_lvgl_targets

else
    echo do nothing
fi

printf "\033[32mbuild successfully\033[0m\n"
