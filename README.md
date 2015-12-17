# Getting Started

1.  [Install nvm](https://github.com/creationix/nvm#install-script) and run

    ```bash
    $ nvm install v4.2.3
    ```

2.  Create database user and database.

    ```bash
    $ sudo -u postgres psql -c "CREATE USER name WITH PASSWORD 'password';"
    $ sudo -u postgres createdb -O name database
    ```

## Server

1.  Run

    ```bash
    $ npm run build && npm run dev
    ```

## Tracker

1.  Create `price-tracker.sh`.

    ```bash
    #!/bin/bash

    export NVM_DIR="/path/to/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    nvm use --silent v4.2.3
    cd /path/to/price-tracker
    PG_CONN=postgres://name:password@127.0.0.1/database npm run track
    ```

    Make it executable.

    ```bash
    $ chmod +x price-tracker.sh
    ```

### Upstart

1.  Create `/etc/init/price-tracker.conf`.

    ```
    # Price Tracker - tracking price daemon
    #
    # Price Tracker can automatically track current price of the products.

    description "Price Tracker"

    start on runlevel [2345]
    stop on runlevel [!2345]

    respawn

    exec /path/to/price-tracker.sh

    console log
    ```

2.  Run

    ```bash
    $ sudo service price-tracker start
    ```
