#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]:-$_}")")"
HIT_SCRIPT_DIR=$SCRIPT_DIR/hit
HIT_PROJECT="$(basename $(cd $SCRIPT_DIR/../ && pwd))"
export HIT_SCRIPT_DIR
export HIT_PROJECT
source $SCRIPT_DIR/hit/test/_hit
source $SCRIPT_DIR/hit/db/_hit
source $SCRIPT_DIR/hit/rails/_hit
source $SCRIPT_DIR/hit/dev/_hit

PS1="HIT-$HIT_PROJECT> "

hit() {
  cd $SCRIPT_DIR/../
  case "$1" in
    test)
      shift
      hit_test
      ;;
    dev)
      shift
      hit_dev "$@"
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
      echo "Usage: hit {dev|test|db|rails|worker}"
      echo "Current HIT Project: $HIT_PROJECT"
      return 1
      ;;
  esac
}
