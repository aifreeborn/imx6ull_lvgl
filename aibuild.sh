#!/bin/bash

rm -rf build
cmake -B build -GNinja -DCMAKE_TOOLCHAIN_FILE=./cmake/user_cross_compile_setup.cmake
cmake --build build
