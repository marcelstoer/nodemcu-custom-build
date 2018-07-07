#!/bin/bash
#
# user_config.h has a number of defines the are replaced according to their
# corresponding env X_???? variable.
#
#  Define                  Uncomment if param        Set to param
#  LUA_FLASH_STORE                >0                      Y
#  SPIFFS_FIXED_LOCATION          >0                      Y
#  SPIFFS_MAX_FILESYSTEM_SIZE     >0                      Y
#  BUILD_FATFS                  "true"
#  DEVELOP_VERSION              "true"
#  SSL_ENABLED                  "true"
#
set -e

# What is carried in the following variables is the sed replacement expression.
# It makes all #defines commented by default.
declare         lfs="// #\\1"
declare spiffs_base="// #\\1"
declare spiffs_size="// #\\1"
declare       fatfs="// #\\1"
declare       debug="// #\\1"
declare         ssl="// #\\1"

#if env var exists and is not "0"
if [ ! -z "${X_LUA_FLASH_STORE}" ] && [ "${X_LUA_FLASH_STORE}" != "0" ]; then
  printf "Enabling LFS, size = %s\\n" "${X_LUA_FLASH_STORE}"
  lfs="#\\1 ${X_LUA_FLASH_STORE}"
fi

if [ ! -z "${X_SPIFFS_FIXED_LOCATION}" ] && [ "${X_SPIFFS_FIXED_LOCATION}" != "0" ]; then
  printf "SPIFFS location offset = %s\\n" "${X_SPIFFS_FIXED_LOCATION}"
  spiffs_base="#\\1 ${X_SPIFFS_FIXED_LOCATION}"
fi

if [ ! -z "${X_SPIFFS_MAX_FILESYSTEM_SIZE}" ] && [ "${X_SPIFFS_MAX_FILESYSTEM_SIZE}" != "0" ]; then
  printf "SPIFFS size = %s\\n" "${X_SPIFFS_MAX_FILESYSTEM_SIZE}"
  spiffs_size="#\\1 ${X_SPIFFS_MAX_FILESYSTEM_SIZE}"
fi

if [ "${X_DEBUG_ENABLED}" == "true" ]; then
  echo "Enabling debug mode"
  debug="#\\1"
fi

if [ "${X_FATFS_ENABLED}" == "true" ]; then
  echo "Enabling FatFS"
  fatfs="#\\1"
fi

if [ "${X_SSL_ENABLED}" == "true" ]; then
  echo "Enabling SSL"
  ssl="#\\1"
fi

# There's no option for sed in-place editing that works on both Unix and macOS
# -> pipe to new file, then rename it
sed -e "s!^.*\\(define *LUA_FLASH_STORE\\).*!$lfs!" \
    -e "s!^.*\\(define *SPIFFS_FIXED_LOCATION\\).*!$spiffs_base!" \
    -e "s!^.*\\(define *SPIFFS_MAX_FILESYSTEM_SIZE\\).*!$spiffs_size!" \
    -e "s!^.*\\(define *BUILD_FATFS\\).*!$fatfs!" \
    -e "s!^.*\\(define *CLIENT_SSL_ENABLE\\).*!$ssl!" \
    -e "s!^.*\\(define *DEVELOP_VERSION\\).*!$debug!" \
    user_config.h > user_config.h.new;

mv user_config.h.new user_config.h;
