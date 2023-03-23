#!/bin/env bash

set -e

echo "Running 'script' for ESP8266"
(
  # https://github.com/nodemcu/nodemcu-firmware/pull/2545 removed the toolchain from the repository but the 1.5.4.1 branch
  # will always depend on it
  if [ -f tools/esp-open-sdk.tar.xz ]; then tar -Jxf tools/esp-open-sdk.tar.xz; elif [ -f tools/esp-open-sdk.tar.gz ]; then tar -zxf tools/esp-open-sdk.tar.gz; fi
  export PATH=$PATH:$PWD/esp-open-sdk/sdk:$PWD/esp-open-sdk/xtensa-lx106-elf/bin
  make LUA="${X_LUA}" all
  cd bin/
  timestamp=$(date "+%Y-%m-%d-%H-%M-%S")
  base_file_name="nodemcu-$X_BRANCH-$X_NUMBER_OF_MODULES-modules-"$timestamp
  file_name_float=$base_file_name"-float.bin"
  srec_cat  -output "${file_name_float}" -binary 0x00000.bin -binary -fill 0xff 0x00000 0x10000 0x10000.bin -binary -offset 0x10000
  cd ../
  make clean
  make LUA="${X_LUA}" EXTRA_CCFLAGS="-DLUA_NUMBER_INTEGRAL"
  cd bin/
  file_name_integer=$base_file_name"-integer.bin"
  srec_cat -output "${file_name_integer}" -binary 0x00000.bin -binary -fill 0xff 0x00000 0x10000 0x10000.bin -binary -offset 0x10000
)
