#!/bin/bash
set -e

git config --global --add safe.directory '*'

exec python launch.py "$@"
