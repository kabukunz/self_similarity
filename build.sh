#!/bin/bash

rm -rf build/CMakeCache.txt

cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
-DCMAKE_C_COMPILER=/usr/local/bin/gcc-11 \
-DCMAKE_CXX_COMPILER=/usr/local/bin/g++-11 \
-H. -B build -G Ninja
