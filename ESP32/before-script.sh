#!/bin/env bash

# current script dir
declare -r SCRIPT_DIR="$( cd $( dirname $0 ) && pwd )"

set -e

_set_headers() {
  # replace modules in user_modules.h by the selected ones
  "${SCRIPT_DIR}"/set-modules.sh
  # set defines in user_config.h according to X_* variables
  "${SCRIPT_DIR}"/set-config.sh
}

_main() {
  echo "Running 'before_script' for ESP32"
  
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
