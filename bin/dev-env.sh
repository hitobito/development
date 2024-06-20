#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]:-$_}")")"
HIT_SCRIPT_DIR=$SCRIPT_DIR/hit
HIT_PROJECT="$(basename $(cd $SCRIPT_DIR/../ && pwd))"
HIT_WAGON_NAMES=$(ls -d "$HIT_SCRIPT_DIR"/../../app/hitobito_* | sed 's|.*/hitobito_||')
export HIT_SCRIPT_DIR
export HIT_PROJECT
export HIT_WAGON_NAMES
source $SCRIPT_DIR/hit/test/_hit
source $SCRIPT_DIR/hit/db/_hit
source $SCRIPT_DIR/hit/rails/_hit
source $SCRIPT_DIR/hit/dev/_hit
source $SCRIPT_DIR/hit/welcome_info

PS1="HIT-$HIT_PROJECT> "

hit_welcome_info

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
