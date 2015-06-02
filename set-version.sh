#!/bin/sh

set -e

X_COMMIT_ID=$(git rev-parse HEAD)
sed 's/#define NODE_VERSION[^_].*/#define NODE_VERSION "NodeMCU custom build by frightanic.com\\n\\tbranch: '$X_BRANCH'\\n\\tcommit: '$X_COMMIT_ID'\\n\\tSSL: '$X_SSL_ENABLED'\\n\\tmodules: '$X_MODULES'\\n"/g' user_version.h > user_version.h.tmp && mv user_version.h.tmp user_version.h
sed 's/#define BUILD_DATE.*/#define BUILD_DATE "\\tbuilt on: '"$(date "+%Y-%m-%d %H:%M")"'\\n"/g' user_version.h > user_version.h.tmp && mv user_version.h.tmp user_version.h
