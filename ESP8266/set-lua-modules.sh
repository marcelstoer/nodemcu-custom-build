#!/bin/bash

# assuming PWD = "nodemcu-firmware" dir
declare -r tgtPath="${PWD}/local"

# lua_modules is currently located in the parent-of-parent of "nodemcu-firmware"
## this can change once firmware contains all lua_modules
declare -r srcPath="$( cd ${PWD}/../../lua_modules && pwd )"

_copy_file() {
  local -r tgtF="$1" ; shift
  local -r srcF="$1" ; shift
  [ -f "${tgtF}" ] && { echo "[ERR] : duplicate named file detected : ${tgtF}" ; return 1 ; }
  [ -f "${srcF}" ] && cp "${srcF}" "${tgtF}"
  return 0
}

_copy_all_files() {
  local -r tgtDir="$1" ; shift
  for i in "$@" ; do
    _copy_file "${tgtDir}/$(basename ${i})" "${i}" || return 1
  done
}

_copy_module() {
  local -r srcDir="${srcPath}/$1" ; shift
  _copy_all_files ${tgtPath}/lua ${srcDir}/lua/* || return 1
  _copy_all_files ${tgtPath}/fs ${srcDir}/fs/* || return 1
}

_copy_all_modules() {
  for i in "$@" ; do
    _copy_module "${i}" || return 1
  done
}

_clean() {
  for i in "${tgtPath}/lua" "${tgtPath}/fs" ; do
    rm -rf ${i}/* || { echo "[ERR] : failed cleaning ${i}/* dir" ; return 1 ; }
  done
}

_main() {
  if [ -n "${X_LUA_MODULES}" ] ; then
    [ ! -d "${tgtPath}" ] && { echo "[ERR] : missing ${tgtPath}" ; return 1 ; }
    [ ! -d "${srcPath}" ] && { echo "[ERR] : missing ${srcPath}" ; return 1 ; }

    _clean || return 1

    _copy_all_modules $( echo ${X_LUA_MODULES} | sed 's/,/ /g' )
  fi
}

_main
