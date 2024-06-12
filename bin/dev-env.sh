#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]:-$_}")")"
source $SCRIPT_DIR/db/_hit
source $SCRIPT_DIR/rails/_hit


# Define the 'hit' command with subcommands
function hit {
  case "$1" in
    test)
      if [[ "$2" == "prep" ]]; then
        $SCRIPT_DIR/test/prep
      else
        $SCRIPT_DIR/test/env
      fi

      ;;
    attach)
      echo "Attaching to process..."
      # Add your attach logic here
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
      echo "Usage: hit {test|attach|db}"
      return 1
      ;;
  esac
}

# Export the command so it can be used in the current session
export -f hit
