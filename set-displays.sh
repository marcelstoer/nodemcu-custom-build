#!/bin/sh

set -e

# replace default U8G I2C/SPI displays with the selected ones
# sed inline in-place editing (-i) isn't used because OS X would require different syntax http://stackoverflow.com/q/22521207/131929

if [ "${X_U8G_DISPLAY_I2C}" == "" ]; then
  #  one *could* delete the default entry if no display is selected...
  #  sed "/^ *U8G_DISPLAY_TABLE_ENTRY.*i2c)/d" u8g_config.h
  :
else
  sed "s/^ *U8G_DISPLAY_TABLE_ENTRY.*i2c)/    U8G_DISPLAY_TABLE_ENTRY($X_U8G_DISPLAY_I2C)/" u8g_config.h > u8g_config.h.tmp && mv u8g_config.h.tmp u8g_config.h
fi

if [ "${X_U8G_DISPLAY_SPI}" == "" ]; then
  #  one *could* delete the default entry if no display is selected...
  #  sed "/^ *U8G_DISPLAY_TABLE_ENTRY.*spi)/d" u8g_config.h
  :
else
  sed "s/^ *U8G_DISPLAY_TABLE_ENTRY.*spi)/    U8G_DISPLAY_TABLE_ENTRY($X_U8G_DISPLAY_SPI)/" u8g_config.h > u8g_config.h.tmp && mv u8g_config.h.tmp u8g_config.h
fi
