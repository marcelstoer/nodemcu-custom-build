#!/bin/bash

set -e

declare -r X_COMMIT_ID=$(git rev-parse HEAD)
declare -r BUILD_DATE="$(date "+%Y-%m-%d %H:%M")"
sed -i 's/#define NODE_VERSION[^_].*/#define NODE_VERSION "NodeMCU custom build by frightanic.com\\n\\tbranch: '$X_BRANCH'\\n\\tcommit: '$X_COMMIT_ID'\\n\\tSSL: '$X_SSL_ENABLED'\\n\\tmodules: '$X_MODULES'\\n"/g' user_version.h
sed -i 's/"unspecified"/"created on '"${BUILD_DATE}"'\\n"/g' user_version.h
