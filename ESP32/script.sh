#!/bin/env bash

set -e

echo "Running 'script' for ESP32"
(
  timestamp=$(date "+%Y-%m-%d-%H-%M-%S")
  image_name="$X_BRANCH-$X_NUMBER_OF_MODULES-modules-$timestamp"

  mkdir bin

  # ---------------------------------------------------------------------------
  # run float build in ./build/float
  # ---------------------------------------------------------------------------
  make MORE_CFLAGS="-DBUILD_DATE='\"'$timestamp'\"'" all
  # package the 3 binaries into a single .bin for 0x0000
  # 0x1000 bootloader.bin
  # 0x8000 partitions.bin
  # 0x10000 NodeMCU.bin
  # current command is a simplification of the one proposed at https://github.com/marcelstoer/docker-nodemcu-build/issues/55#issuecomment-440830227
  srec_cat -output bin/nodemcu-"${image_name}"-float.bin -binary build/bootloader/bootloader.bin -binary -offset 0x1000 -fill 0xff 0x0000 0x8000 build/partitions.bin -binary -offset 0x8000 -fill 0xff 0x8000 0x10000 build/NodeMCU.bin -binary -offset 0x10000

  make clean

  # ---------------------------------------------------------------------------
  # run integer build in ./build/integer
  # ---------------------------------------------------------------------------
  make MORE_CFLAGS="-DLUA_NUMBER_INTEGRAL -DBUILD_DATE='\"'$timestamp'\"'" all
  srec_cat -output bin/nodemcu-"${image_name}"-integer.bin -binary build/bootloader/bootloader.bin -binary -offset 0x1000 -fill 0xff 0x0000 0x8000 build/partitions.bin -binary -offset 0x8000 -fill 0xff 0x8000 0x10000 build/NodeMCU.bin -binary -offset 0x10000

  ls -al bin
)
