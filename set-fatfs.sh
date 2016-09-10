#!/bin/sh

set -e

echo "FatFs enabled:" "${X_FATFS_ENABLED}";

if [ "${X_FATFS_ENABLED}" = "true" ]; then
  echo "Enabling FatFs in user_config.h"
  sed -e 's/\/\/ *#define BUILD_FATFS/#define BUILD_FATFS/g' user_config.h > user_config.h.tmp;
else
  echo "Disabling FatFs in user_config.h"
  sed -e 's/#define BUILD_FATFS/\/\/#define BUILD_FATFS/g' user_config.h > user_config.h.tmp;
fi
mv user_config.h.tmp user_config.h;
