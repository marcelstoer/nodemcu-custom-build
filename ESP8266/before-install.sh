#!/bin/env bash

set -e

echo "Running 'before_install' for ESP8266"
(
  SCRIPT_DIR=$TRAVIS_BUILD_DIR/ESP8266

  # dig in and modify those config files
  cd nodemcu-firmware/app/include || exit

  # replace modules in user_modules.h by the selected ones
  "$SCRIPT_DIR"/set-modules.sh
  # set defines in user_config.h according to X_* variables
  "$SCRIPT_DIR"/set-config.sh
  # replace fonts in u8g_config.h by the selected ones
  "$SCRIPT_DIR"/set-fonts.sh
  # set I2C/SPI displays in u8g_config.h and ucg_config.h
  "$SCRIPT_DIR"/set-displays.sh
  # replace version strings in user_version.h
  "$SCRIPT_DIR"/set-version.sh

  cat user_modules.h
  cat user_config.h
  cat u8g*.h
  cat ucg_config.h
  cat user_version.h

  # back to where we came from
  cd "$TRAVIS_BUILD_DIR" || exit
)
