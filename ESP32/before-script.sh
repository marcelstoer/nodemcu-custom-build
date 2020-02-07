#!/bin/env bash

set -e

echo "Running 'before_script' for ESP32"
(
  make defconfig  # -> will also download and uncompress the toolchain

  # ---------------------------------------------------------------------------
  # select modules
  # ---------------------------------------------------------------------------
  # disable all modules
  sed -ri 's/(CONFIG_LUA_MODULE_.*=).{0,1}/\1/' sdkconfig
  # enable the selected ones
  echo "Enabling modules $X_MODULES"
  mapfile -t modules < <(echo "$X_MODULES" | tr , '\n' | tr '[:lower:]' '[:upper:]')
  for m in "${modules[@]}"; do
    sed -ri "s/(CONFIG_LUA_MODULE_$m=)/\1y/" sdkconfig
  done

  # ---------------------------------------------------------------------------
  # set SSL/TLS
  # ---------------------------------------------------------------------------
  if [ "${X_SSL_ENABLED}" == "true" ]; then
    echo "Enabling SSL/TLS for mbed TLS and MQTT"
    sed -ri 's/(CONFIG_MBEDTLS_TLS_ENABLED=).{0,1}/\1y/' sdkconfig
    sed -ri 's/(CONFIG_MQTT_TRANSPORT_SSL=).{0,1}/\1y/' sdkconfig
  else
    echo "Disabling SSL/TLS for mbed TLS and MQTT"
    sed -ri 's/(CONFIG_MBEDTLS_TLS_ENABLED=).{0,1}/\1/' sdkconfig
    sed -ri 's/(CONFIG_MQTT_TRANSPORT_SSL=).{0,1}/\1/' sdkconfig
  fi

  # ---------------------------------------------------------------------------
  # set FatFS i.e. enable the SDMMC module in case the user forgot
  # ---------------------------------------------------------------------------
  if [ "${X_FATFS_ENABLED}" == "true" ]; then
    echo "Enabling FatFS/SDMMC"
    sed -ri "s/(CONFIG_LUA_MODULE_SDMMC=).{0,1}/\1y/" sdkconfig
  fi

  # ---------------------------------------------------------------------------
  # set debug mode/level
  # ---------------------------------------------------------------------------
  if [ "${X_DEBUG_ENABLED}" == "true" ]; then
    echo "Enabling debug mode"
    sed -ri "s/(CONFIG_LOG_DEFAULT_LEVEL_INFO=).{0,1}/\1/" sdkconfig
    sed -ri "s/(CONFIG_LOG_DEFAULT_LEVEL_DEBUG=).{0,1}/\1y/" sdkconfig
    sed -ri "s/(CONFIG_LOG_DEFAULT_LEVEL=).{0,1}/\14/" sdkconfig
  fi

  cat sdkconfig

  # below inspired by https://github.com/marcelstoer/docker-nodemcu-build/blob/master/build-esp32

  # ---------------------------------------------------------------------------
  # set version(s)
  # ---------------------------------------------------------------------------
  version_file=components/platform/include/user_version.h
  lua_header_file=components/lua/lua.h

  export BUILD_DATE COMMIT_ID BRANCH SSL MODULES SDK_VERSION
  BUILD_DATE="$(date "+%Y-%m-%d %H:%M")"
  COMMIT_ID="$(git rev-parse HEAD)"
  BRANCH="$(git rev-parse --abbrev-ref HEAD | sed -r 's/[\/\\]+/_/g')"
  # 'git submodule status' -> 7313e39fde0eb0a47a60f31adccd602c82a8d5ad sdk/esp32-esp-idf (v3.2-dev-1239-g7313e39)
  # -> get text between ()
  SDK_VERSION="$(git submodule status|grep esp32|sed -r 's/.*\((.+)\)/\1/')"
  # If the submodule isn't linked to a released/tagged version the above commands would set SDK_VERSION to
  # "7313e39fde0eb0a47a60f31adccd602c82a8d5ad sdk/esp32-esp-idf" (w/o the quotes).
  # -> check and get the short Git revion hash instead
  if [ ${#SDK_VERSION} -ge 40 ]; then SDK_VERSION=${SDK_VERSION:0:7}; fi
  # If it's still empty then set it to a dummy to ensure further operations don't fail.
  if [ -z "$SDK_VERSION" ]; then SDK_VERSION="n/a"; fi

  sed -i '/#define NODE_VERSION[[:space:]]/ s/$/ " '"$USER_PROLOG"'\\n\\tbranch: '"$BRANCH"'\\n\\tcommit: '"$COMMIT_ID"'\\n\\tSSL: '"$X_SSL_ENABLED"'\\n\\tmodules: '"$X_MODULES"'\\n"/g' "$version_file"
  sed -i 's/"unspecified"/"created on '"$BUILD_DATE"'\\n"/g' "$version_file"
  sed -i '/#define LUA_RELEASE[[:space:]]/ s/$/ " on ESP-IDF '"$SDK_VERSION"'"/g' "$lua_header_file"

  cat "$version_file"
  grep LUA_RELEASE "$lua_header_file"
)
