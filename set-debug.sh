#!/bin/sh

set -e

echo "Debug enabled: " ${X_DEBUG_ENABLED};

if [ "${X_DEBUG_ENABLED}" == "true" ]; then
  echo "Enabling debug mode in user_config.h"
  # http://stackoverflow.com/q/18272379/131929
  awk 'NR==4{print "#define NODE_DEBUG\n#define COAP_DEBUG\n"}1' user_config.h > user_config.h.tmp && mv user_config.h.tmp user_config.h;
fi
