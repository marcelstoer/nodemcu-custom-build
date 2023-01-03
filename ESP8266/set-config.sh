#!/bin/bash
#
# user_config.h has a number of defines the are replaced according to their
# corresponding env X_???? variable.
#
#  Define                  Uncomment if param        Set to param   SDK3.0
#  LUA_FLASH_STORE                >0                      Y           Y
#  SPIFFS_FIXED_LOCATION          >0                      Y           Y
#  SPIFFS_MAX_FILESYSTEM_SIZE     >0                      Y           Y
#  X_SPIFFS_SIZE_1M_BOUNDARY    "true"                                Y
#  BUILD_FATFS                  "true"                                Y
#  DEVELOP_VERSION              "true"                                Y
#  SSL_ENABLED                  "true"                                Y
#  LUA_INIT_STRING
#
set -e

#if env var exists and is not "0" then overwrite default
if [ -n "${X_LUA_FLASH_STORE}" ] && [ "${X_LUA_FLASH_STORE}" != "0" ]; then
  printf "Enabling LFS, size = %s\\n" "${X_LUA_FLASH_STORE}"
  sed -e "s!^.*#define LUA_FLASH_STORE .*!#define LUA_FLASH_STORE ${X_LUA_FLASH_STORE}!" user_config.h > user_config.h.new;
  mv user_config.h.new user_config.h;
fi

if [ -n "${X_SPIFFS_FIXED_LOCATION}" ] && [ "${X_SPIFFS_FIXED_LOCATION}" != "0" ]; then
  printf "SPIFFS location offset = %s\\n" "${X_SPIFFS_FIXED_LOCATION}"
  sed "s!^.*#define SPIFFS_FIXED_LOCATION .*!#define SPIFFS_FIXED_LOCATION ${X_SPIFFS_FIXED_LOCATION}!" user_config.h > user_config.h.new;
  mv user_config.h.new user_config.h;
fi

if [ -n "${X_SPIFFS_MAX_FILESYSTEM_SIZE}" ] && [ "${X_SPIFFS_MAX_FILESYSTEM_SIZE}" != "0" ]; then
  printf "SPIFFS size = %s\\n" "${X_SPIFFS_MAX_FILESYSTEM_SIZE}"
  sed "s!^.*#define SPIFFS_MAX_FILESYSTEM_SIZE.*!#define SPIFFS_MAX_FILESYSTEM_SIZE ${X_SPIFFS_MAX_FILESYSTEM_SIZE}!" user_config.h > user_config.h.new;
  mv user_config.h.new user_config.h;
fi

if [ ! -z "${X_LUA_INIT_STRING}" ]; then
  printf "LUA_INIT_STRING = %s\\n" "${X_LUA_INIT_STRING}"
  sed "s!^.*#define LUA_INIT_STRING .*!#define LUA_INIT_STRING \x22${X_LUA_INIT_STRING}\x22!" user_config.h > user_config.h.new;
  mv user_config.h.new user_config.h;
fi

# What is carried in the following variables is the sed replacement expression.
# It makes all #defines commented by default.
declare       fatfs="//#\\1"
declare       debug="//#\\1"
declare         ssl="//#\\1"
declare    spiffs1m="//#\\1"


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

if [ "${X_SPIFFS_SIZE_1M_BOUNDARY}" == "true" ]; then
  echo "Enabling SPIFFS 1M boundary"
  spiffs1m="#\\1"
fi

# Do sed via temp file for macOS compatability
sed -e "s!^.*\\(define *BUILD_FATFS\\).*!$fatfs!" \
    -e "s!^.*\\(define *CLIENT_SSL_ENABLE\\).*!$ssl!" \
    -e "s!^.*\\(define *DEVELOP_VERSION\\).*!$debug!" \
    -e "s!^.*\\(define *SPIFFS_SIZE_1M_BOUNDARY\\).*!$spiffs1m!" \
    user_config.h > user_config.h.new;
mv user_config.h.new user_config.h;

# Set the flash to autosize from which ever value the firmware developers chose
# as a default.
echo "Setting flash size to 'auto'"
sed "s/#define FLASH_.*/#define FLASH_AUTOSIZE/" user_config.h > user_config.h.new;
mv user_config.h.new user_config.h;
