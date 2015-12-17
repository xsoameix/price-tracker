#!/bin/bash

export NVM_DIR="/path/to/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm use --silent v4.2.3
cd /path/to/price-tracker
PG_CONN=postgres://name:password@127.0.0.1/database \
    node_modules/.bin/lsc tracker/amazon
