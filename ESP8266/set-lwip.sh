#!/bin/bash

set -e

function _main {
    env | grep X_LWIP_ | awk -F '=' '{ print $1,$2 }' | while read a b
    do
        local c=$( echo ${a} | sed 's/X_LWIP_//' )
        sed -Ei "s/#define ${c} .+/#define ${c} ${b}/" lwipopts.h || return 1
    done
}

_main