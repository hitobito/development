#!/bin/bash

# This script will be run _inside_ the container everytime you create a devontainer. This happens after the initialize.sh script.

sudo gem install debug
sudo gem install ruby-lsp

/usr/local/bin/rails-entrypoint.sh echo "Finished initializing!"
