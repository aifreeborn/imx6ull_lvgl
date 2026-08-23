#!/bin/bash

export TOP_PATH=`pwd`
export OUT_PATH=${TOP_PATH}/out
RELEASE_PATH=${OUT_PATH}/release

if [ -d ${OUT_PATH} ];then
    rm -rf ${OUT_PATH}
fi

pushd ./external/libevdev
./autogen.sh
./configure --host=arm-none-linux-gnueabihf CC=arm-none-linux-gnueabihf-gcc --prefix=${OUT_PATH}/_install
make -j4 && make install
popd


export PKG_CONFIG_PATH=${OUT_PATH}/_install/lib/pkgconfig:$PKG_CONFIG_PATH
cmake -B ${OUT_PATH}/build -GNinja -DCMAKE_TOOLCHAIN_FILE=./cmake/user_cross_compile_setup.cmake
cmake --build ${OUT_PATH}/build


mkdir ${RELEASE_PATH}
cp -af ${OUT_PATH}/build/bin/lvglsim ${RELEASE_PATH}/
cp -af ${OUT_PATH}/_install ${RELEASE_PATH}/
