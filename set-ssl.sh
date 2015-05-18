#!/bin/sh

set -e

echo "SSL enabled:" ${X_SSL_ENABLED};

if [ "${X_SSL_ENABLED}" != "true" ]; then
  echo "Disabling SSL in user_config.h"
  sed -e 's/#define CLIENT_SSL_ENABLE/\/\/ #define CLIENT_SSL_ENABLE/g' user_config.h > user_config.h.tmp && mv user_config.h.tmp user_config.h;
fi
