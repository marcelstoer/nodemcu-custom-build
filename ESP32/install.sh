#!/bin/env bash

set -e

echo "Running 'install' for ESP32"
(
  python -m pip install setuptools
  python -m pip install --user -r "$PWD"/sdk/esp32-esp-idf/requirements.txt
)
