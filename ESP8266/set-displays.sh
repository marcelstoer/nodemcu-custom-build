#!/bin/sh

set -e

# replace default U8G and U8G2 I2C/SPI displays with the selected ones
# sed inline in-place editing (-i) isn't used because OS X would require different syntax http://stackoverflow.com/q/22521207/131929

if [ "${X_U8G_DISPLAY_I2C}" = "" ]; then
  # one *could* delete the default entry if no display is selected...
  # sed "/^ *U8G_DISPLAY_TABLE_ENTRY.*i2c)/d" u8g_config.h
  :
else
  if test -e "u8g_config.h"; then
    sed "s/^ *U8G_DISPLAY_TABLE_ENTRY.*i2c)/    U8G_DISPLAY_TABLE_ENTRY($X_U8G_DISPLAY_I2C)/" u8g_config.h > u8g_config.h.tmp && mv u8g_config.h.tmp u8g_config.h
  fi

  if test -e "u8g2_displays.h"; then
    cat <<EOF > u8g2_displays.h.tmp
#define U8G2_DISPLAY_TABLE_I2C_EXTRA \\
  U8G2_DISPLAY_TABLE_ENTRY(u8g2_Setup_${X_U8G_DISPLAY_I2C}_f, ${X_U8G_DISPLAY_I2C})
EOF
    cat u8g2_displays.h >> u8g2_displays.h.tmp && mv u8g2_displays.h.tmp u8g2_displays.h
  fi
fi

if [ "${X_U8G_DISPLAY_SPI}" = "" ]; then
  # one *could* delete the default entry if no display is selected...
  # sed "/^ *U8G_DISPLAY_TABLE_ENTRY.*spi)/d" u8g_config.h
  :
else
  if test -e "u8g_config.h"; then
    sed "s/^ *U8G_DISPLAY_TABLE_ENTRY.*spi)/    U8G_DISPLAY_TABLE_ENTRY($X_U8G_DISPLAY_SPI)/" u8g_config.h > u8g_config.h.tmp && mv u8g_config.h.tmp u8g_config.h
  fi

  if test -e "u8g2_displays.h"; then
    cat <<EOF > u8g2_displays.h.tmp
#define U8G2_DISPLAY_TABLE_SPI_EXTRA \\
  U8G2_DISPLAY_TABLE_ENTRY(u8g2_Setup_${X_U8G_DISPLAY_SPI}_f, ${X_U8G_DISPLAY_SPI})
EOF
    cat u8g2_displays.h >> u8g2_displays.h.tmp && mv u8g2_displays.h.tmp u8g2_displays.h
  fi
fi


# replace default UCG SPI displays with the selected one

if [ "${X_UCG_DISPLAY_SPI}" = "" ]; then
  # one *could* delete the default entry if no display is selected...
  # sed "/^ *UCG_DISPLAY_TABLE_ENTRY.*)/d" ucg_config.h
  :
else
  # delete the first of two default entries and replace the second
  sed "/^ *UCG_DISPLAY_TABLE_ENTRY(ili.*)/d" ucg_config.h > ucg_config.h.tmp && mv ucg_config.h.tmp ucg_config.h
  sed "s/^ *UCG_DISPLAY_TABLE_ENTRY.*)/    UCG_DISPLAY_TABLE_ENTRY($X_UCG_DISPLAY_SPI)/" ucg_config.h > ucg_config.h.tmp && mv ucg_config.h.tmp ucg_config.h
fi
