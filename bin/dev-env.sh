#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]:-$_}")")"
HIT_SCRIPT_DIR=$SCRIPT_DIR/hit
export HIT_SCRIPT_DIR
source $SCRIPT_DIR/hit/test/_hit
source $SCRIPT_DIR/hit/db/_hit
source $SCRIPT_DIR/hit/rails/_hit

hit() {
  case "$1" in
    test)
      shift
      hit_test
      ;;
    db)
      shift
      hit_db "$@"
      ;;
    rails)
      shift
      hit_rails "$@"
      ;;
    *)
      echo "Usage: hit {test|db|rails|worker}"
      return 1
      ;;
  esac
}
