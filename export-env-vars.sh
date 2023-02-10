#!/bin/bash

_get_key_val() {
  local -r fName="$1" ; shift
  grep -E "^${fName}=" build.config | cut -f 2- -d '='
}

_nvl() {
  local -r val="$1" ; shift
  local -r defVal="$1" ; shift
  if [ "xx" == "x${val}x" ] ; then
    echo "${defVal}"
  else
    echo "${val}"
  fi
}

_get_val_def() {
  local -r fName="$1" ; shift
  local -r defVal="$1" ; shift
  local -r val="$( _get_key_val ${fName} )"
  _nvl "${val}" "${defVal}"
}

_concat() {
  local second=false
  while read line ; do
    if ${second} ; then 
      echo -n ","
    fi
    echo -n "${line}"
    second=true
  done
}

_get_val() {
  local -r fName="$1" ; shift
  _get_key_val "${fName}" | _concat
}

_exp_if_exists() {
  local -r fName="$1" ; shift
  local -r eName="$1" ; shift
  local -r val="$( _get_val ${fName} "$@" )"
  if [ "xx" != "x${val}x" ] ; then
    cat<<EOF
export ${eName}='$( echo ${val} | sed "s/'/\\\\x27/g" )'
EOF
  fi
}

_exp() {
  local -r X_MODULES=$( _get_val modules )
  cat <<EOF
export USER_PROLOG='$(                    _get_val_def prolog 'built on nodemcu-build.com provided by frightanic.com' )'
export X_EMAIL=$(                         _get_val email )
export X_BRANCH='$(                       _get_val branch )'
export X_MODULES='${X_MODULES}'
export X_U8G_FONTS='$(                    _get_val u8g-fonts )'
export X_U8G_DISPLAY_I2C='$(              _get_val u8g-display-i2c )'
export X_U8G_DISPLAY_SPI='$(              _get_val u8g-display-spi )'
export X_UCG_DISPLAY_SPI='$(              _get_val ucg-display-spi )'
export X_LUA_FLASH_STORE=$(               _get_val lfs-size )
export X_SPIFFS_FIXED_LOCATION=$(         _get_val spiffs-base )
export X_SPIFFS_MAX_FILESYSTEM_SIZE=$(    _get_val spiffs-size )
export X_SSL_ENABLED=$(                   _get_val ssl-enabled )
export X_DEBUG_ENABLED=$(                 _get_val debug-enabled )
export X_FATFS_ENABLED=$(                 _get_val fatfs-enabled )
export X_NUMBER_OF_MODULES=$(echo "${X_MODULES}" | awk -F\, '{print NF}')
EOF
  _exp_if_exists spiffs-1mboundary X_SPIFFS_SIZE_1M_BOUNDARY
  _exp_if_exists repository X_REPO
  _exp_if_exists lua X_LUA
  _exp_if_exists lua-init X_LUA_INIT_STRING
  _exp_if_exists lua-modules X_LUA_MODULES

  _exp_if_exists lwip-pbuf-pool-size X_LWIP_PBUF_POOL_SIZE
  _exp_if_exists lwip-mem-size X_LWIP_MEM_SIZE
  _exp_if_exists lwip-tcp-mss X_LWIP_TCP_MSS
} 

declare outFile=./.env-vars
if [ "xx" != "x${1}x" ] ; then
  outFile="$1"
fi

_exp > ${outFile}

cat ${outFile}
