#!/bin/bash
set -e

function _set {
  local key="$1" ; shift
  local val="$1" ; shift
  echo "${key} = ${val}"
  sed -ri "s!^[# ]*${key}[= ].*\$!${key}=${val}!" sdkconfig || return 1
}

function _set_if_str {
  if [ -v ${2} ]; then
    _set "${1}" "\x22$(echo ${!2})\x22"
  fi
}

function _set_if_else {
  if [ -v ${2} ]; then
    _set "${1}" "${3}"
  else
    _set "${1}" "${4}"
  fi
}

function _set_yes_no {
  _set_if_else "$1" "$2" y n
}

function _set_info {
  # below inspired by https://github.com/marcelstoer/docker-nodemcu-build/blob/master/build-esp32

  # ---------------------------------------------------------------------------
  # set version(s)
  # ---------------------------------------------------------------------------
  version_file=components/platform/include/user_version.h
  lua_header_file=components/lua/lua-5.$( [ "x${X_BRANCH_NATURE}x" == "xesp8266x" ] && echo 1 || echo 3 )/lua.h

  local -r BUILD_DATE="$(date "+%Y-%m-%d %H:%M")"
  local -r COMMIT_ID="$(git rev-parse HEAD)"
  local -r BRANCH="$(git rev-parse --abbrev-ref HEAD | sed -r 's/[\/\\]+/_/g')"
  # 'git submodule status' -> 7313e39fde0eb0a47a60f31adccd602c82a8d5ad sdk/esp32-esp-idf (v3.2-dev-1239-g7313e39)
  # -> get text between ()
  local SDK_VERSION="$(git submodule status|grep esp32|sed -r 's/.*\((.+)\)/\1/')"
  # If the submodule isn't linked to a released/tagged version the above commands would set SDK_VERSION to
  # "7313e39fde0eb0a47a60f31adccd602c82a8d5ad sdk/esp32-esp-idf" (w/o the quotes).
  # -> check and get the short Git revion hash instead
  if [ ${#SDK_VERSION} -ge 40 ]; then SDK_VERSION=${SDK_VERSION:0:7}; fi
  # If it's still empty then set it to a dummy to ensure further operations don't fail.
  if [ -z "$SDK_VERSION" ]; then SDK_VERSION="n/a"; fi

  sed -i '/#define NODE_VERSION[[:space:]]/ s/$/ " '"$USER_PROLOG"'\\n\\tbranch: '"$BRANCH"'\\n\\tcommit: '"$COMMIT_ID"'\\n\\tSSL: '"$X_SSL_ENABLED"'\\n\\tmodules: '"$X_MODULES"'\\n"/g' "${version_file}"
  sed -i 's/"unspecified"/"created on '"$BUILD_DATE"'\\n"/g' "${version_file}"
  sed -i '/#define LUA_RELEASE[[:space:]]/ s/$/ " on ESP-IDF '"$SDK_VERSION"'"/g' "${lua_header_file}"

  #cat "${version_file}"
  #grep LUA_RELEASE "${lua_header_file}"
}

function _set_partitions {
  local -r part_csv=components/platform/partitions.csv
  [ -f "${part_csv}" ] || { echo "[ERR] : expected but missing $(pwd)${part_csv}" && return 1 ; }
  if [ -v X_LUA_FLASH_STORE ] ; then
    sed -ri "s!lfs,.*!lfs,0xC2, 0x01, ,${X_LUA_FLASH_STORE}!" ${part_csv}
  fi
  if [ -v X_SPIFFS_MAX_FILESYSTEM_SIZE ] ; then
    sed -ri "s!storage,.*!storage, data, spiffs, ,${X_SPIFFS_MAX_FILESYSTEM_SIZE}!" ${part_csv}
  fi
}

function _set_lua_ver {
  # clear defaults
  sed -ri 's/(CONFIG_LUA_VERSION_.*)=.{0,1}/# \1 is not set/' sdkconfig || return 1
  _set_yes_no CONFIG_LUA_VERSION_${X_LUA} X_LUA              || return 1
}

function _main {
  # Lua related
  _set_lua_ver                                               || return 1
  _set_if_str CONFIG_LUA_INIT_STRING X_LUA_INIT_STRING       || return 1

  # SSL on/off
  _set_yes_no CONFIG_MBEDTLS_TLS_SERVER X_SSL_ENABLED        || return 1
  _set_yes_no CONFIG_MBEDTLS_TLS_CLIENT X_SSL_ENABLED        || return 1
  _set_yes_no CONFIG_MBEDTLS_TLS_ENABLED X_SSL_ENABLED       || return 1
  _set_yes_no CONFIG_MQTT_TRANSPORT_SSL X_SSL_ENABLED        || return 1

  # set SDMMC module in case the user forgot
  _set_yes_no CONFIG_NODEMCU_CMODULE_SDMMC X_FATFS_ENABLED   || return 1

  _set_yes_no CONFIG_LOG_DEFAULT_LEVEL_INFO X_DEBUG_ENABLED  || return 1
  _set_yes_no CONFIG_LOG_DEFAULT_LEVEL_DEBUG X_DEBUG_ENABLED || return 1
  _set_if_else CONFIG_LOG_DEFAULT_LEVEL X_DEBUG_ENABLED 3 4  || return 1

  _set_info || return 1

  _set_partitions || return 1
}

_main
