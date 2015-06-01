#!/bin/sh

set -e

sed 's/#define NODE_VERSION[^_].*/#define NODE_VERSION "NodeMCU custom build by frightanic.com\\n\\tbranch: '$X_BRANCH'\\n\\tSSL: '$X_SSL_ENABLED'\\n\\tmodules: '$X_MODULES'\\n"/g' user_version.h > user_version.h.tmp && mv user_version.h.tmp user_version.h
sed 's/#define BUILD_DATE.*/#define BUILD_DATE "\\tbuilt on: '$(date "+%Y-%m-%d")'\\n"/g' user_version.h > user_version.h.tmp && mv user_version.h.tmp user_version.h
