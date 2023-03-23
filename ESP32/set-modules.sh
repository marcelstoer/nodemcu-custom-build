#!/bin/bash

set -e

# disable all modules
sed -ri 's/[# ]*(CONFIG_NODEMCU_CMODULE_.*)[= ].*/#\1/' sdkconfig
sed -ri 's/[# ]*(CONFIG_NODEMCU_CMODULE_.*)$/#\1/' sdkconfig

# enable the selected ones
echo "Enabling modules ${X_MODULES}"
mapfile -t modules < <( echo "${X_MODULES}" | tr , '\n' | tr '[:lower:]' '[:upper:]' )

for m in "${modules[@]}"; do
    sed -ri "s/^#(CONFIG_NODEMCU_CMODULE_${m})$/\1=y/" sdkconfig
done
