#!/bin/bash

X_MODULES=$(grep -E '^modules=' build.config | cut -f 2- -d '=')

{
  echo "export USER_PROLOG='built on nodemcu-build.com provided by frightanic.com'"
  echo "export X_EMAIL=$(grep -E '^email=' build.config | cut -f 2- -d '=')"
  echo "export X_BRANCH=$(grep -E '^branch=' build.config | cut -f 2- -d '=')"
  echo "export X_MODULES='""$X_MODULES""'"
  echo "export X_U8G_FONTS='$(grep -E '^u8g-fonts=' build.config | cut -f 2- -d '=')'"
  echo "export X_U8G_DISPLAY_I2C='$(grep -E '^u8g-display-i2c=' build.config | cut -f 2- -d '=')'"
  echo "export X_U8G_DISPLAY_SPI='$(grep -E '^u8g-display-spi=' build.config | cut -f 2- -d '=')'"
  echo "export X_UCG_DISPLAY_SPI='$(grep -E '^ucg-display-spi=' build.config | cut -f 2- -d '=')'"
  echo "export X_LUA_FLASH_STORE=$(grep -E '^lfs-size=' build.config | cut -f 2- -d '=')"
  echo "export X_SPIFFS_FIXED_LOCATION=$(grep -E '^spiffs-base=' build.config | cut -f 2- -d '=')"
  echo "export X_SPIFFS_MAX_FILESYSTEM_SIZE=$(grep -E '^spiffs-size=' build.config | cut -f 2- -d '=')"
  echo "export X_SSL_ENABLED=$(grep -E '^ssl-enabled=' build.config | cut -f 2- -d '=')"
  echo "export X_DEBUG_ENABLED=$(grep -E '^debug-enabled=' build.config | cut -f 2- -d '=')"
  echo "export X_FATFS_ENABLED=$(grep -E '^fatfs-enabled=' build.config | cut -f 2- -d '=')"
  echo "export X_NUMBER_OF_MODULES=$(echo "$X_MODULES" | awk -F\, '{print NF}')"
} >> ./.env-vars

cat ./.env-vars
