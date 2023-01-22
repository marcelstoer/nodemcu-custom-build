#!/bin/bash

# current script dir
declare -r SCRIPT_DIR="$( cd $( dirname $0 ) && pwd )"

set -e

_set_headers() {
  # dig in and modify those config files
  cd app/include || { echo "[ERR] : expected but missing $(pwd)/app/include" && return 1 ; }

  # replace modules in user_modules.h by the selected ones
  "${SCRIPT_DIR}"/set-modules.sh
  # set defines in user_config.h according to X_* variables
  "${SCRIPT_DIR}"/set-config.sh
  # replace fonts in u8g_config.h by the selected ones
  "${SCRIPT_DIR}"/set-fonts.sh
  # set I2C/SPI displays in u8g_config.h and ucg_config.h
  "${SCRIPT_DIR}"/set-displays.sh
  # replace version strings in user_version.h
  "${SCRIPT_DIR}"/set-version.sh
  # replace LWIP settings in lwipopts.h
  "${SCRIPT_DIR}"/set-lwip.sh
}

_main() {
  echo "Running 'before_script' for ESP8266"

  ( _set_headers ) || return 1

  # prepare local/{lua,fs} folders out of lua_modules
  "${SCRIPT_DIR}"/set-lua-modules.sh

  # cat user_modules.h
  # cat user_config.h
  # cat u8g*.h
  # cat ucg_config.h
  # cat user_version.h
}

# subshell due to "cd" command inside
_main
