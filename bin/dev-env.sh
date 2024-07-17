#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]:-$_}")")"

bash --rcfile $SCRIPT_DIR/hit/_hit
