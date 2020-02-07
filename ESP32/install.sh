#!/bin/env bash

set -e

echo "Running 'install' for ESP32"
(
  /usr/bin/python -m pip install setuptools
  /usr/bin/python -m pip install --user -r "$PWD"/sdk/esp32-esp-idf/requirements.txt
)
