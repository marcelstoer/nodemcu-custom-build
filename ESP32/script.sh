#!/bin/env bash

set -e

echo "Running 'script' for ESP32"
(
  export BUILD_DIR_BASE
  timestamp=$(date "+%Y-%m-%d-%H-%M-%S")
  image_name="$X_BRANCH-$X_NUMBER_OF_MODULES-modules-$timestamp"

  toolchain_dir=$(find tools/toolchains -name "esp32-linux-x86_64*" -type d -exec basename {} \;)
  export PATH=$PWD/tools/toolchains/$toolchain_dir/bin:$PATH

  mkdir bin

  # ---------------------------------------------------------------------------
  # run float build in ./build/float
  # ---------------------------------------------------------------------------
  BUILD_DIR_BASE=$(pwd)/build/float
  make MORE_CFLAGS="-DBUILD_DATE='\"'$timestamp'\"'" all
  # package the 3 binaries into a single .bin for 0x0000
  # 0x1000 bootloader.bin
  # 0x8000 partitions.bin
  # 0x10000 NodeMCU.bin
  # current command is a simplification of the one proposed at https://github.com/marcelstoer/docker-nodemcu-build/issues/55#issuecomment-440830227
  srec_cat -output bin/nodemcu-"${image_name}"-float.bin -binary "$BUILD_DIR_BASE"/bootloader/bootloader.bin -binary -offset 0x1000 -fill 0xff 0x0000 0x8000 "$BUILD_DIR_BASE"/partitions.bin -binary -offset 0x8000 -fill 0xff 0x8000 0x10000 "$BUILD_DIR_BASE"/NodeMCU.bin -binary -offset 0x10000

  # ---------------------------------------------------------------------------
  # run integer build in ./build/integer
  # ---------------------------------------------------------------------------
  BUILD_DIR_BASE=$(pwd)/build/integer
  make MORE_CFLAGS="-DLUA_NUMBER_INTEGRAL -DBUILD_DATE='\"'$timestamp'\"'" all
  srec_cat -output bin/nodemcu-"${image_name}"-integer.bin -binary "$BUILD_DIR_BASE"/bootloader/bootloader.bin -binary -offset 0x1000 -fill 0xff 0x0000 0x8000 "$BUILD_DIR_BASE"/partitions.bin -binary -offset 0x8000 -fill 0xff 0x8000 0x10000 "$BUILD_DIR_BASE"/NodeMCU.bin -binary -offset 0x10000

  ls -al bin
)
