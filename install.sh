#!/bin/bash

# Install node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
node="v4.2.3"
nvm install $node

# Configure database
system=`readlink -f /sbin/init`
upstart=/sbin/init
systemd=*/lib/systemd/systemd
case "$system" in
    $upstart)
        sudo service postgresql start
        ;;
    $systemd)
        sudo systemctl start postgresql
        ;;
esac
hba=`sudo -iu postgres psql -tAc 'SHOW hba_file;'`
sudo sed -i -E 's/^(host(\s+\S+){3}\s+)\S+/\1md5/' $hba
case "$system" in
    $upstart)
        sudo service postgresql reload
        ;;
    $systemd)
        sudo systemctl reload postgresql
        ;;
esac

# Create database user and database.
password=`date +%s | sha256sum | base64 | head -c 32`
created="SELECT 1 FROM pg_roles WHERE rolname = 'price';"
if [ -x `sudo -iu postgres psql -tAc "$created"` ]; then
    sudo -iu postgres psql -c "CREATE USER price WITH PASSWORD '$password';"
    sudo -iu postgres createdb -O price pricedb
else
    sudo -iu postgres psql -c "ALTER USER price WITH PASSWORD '$password';"
fi

# Setup server
npm install
export PG_CONN=postgres://price:$password@127.0.0.1/pricedb
npm run setup

# Setup price-tracker
cat > price-tracker << EOL
#!/bin/bash

export NVM_DIR="$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"
nvm use --silent $node
cd $PWD
export PG_CONN=postgres://price:$password@127.0.0.1/pricedb
npm run start
EOL
chmod +x price-tracker

read -r -d '' upstart_service << EOL
# Price Tracker - tracking price daemon
#
# Price Tracker can automatically track current price of the products.

description "Price Tracker"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

exec $PWD/price-tracker

console log
EOL

read -r -d '' systemd_service << EOL
# Price Tracker - tracking price daemon
#
# Price Tracker can automatically track current price of the products.

[Unit]
Description=Price Tracker

[Service]
ExecStart=$PWD/price-tracker

[Install]
WantedBy=multi-user.target
EOL

case "$system" in
    $upstart)
        # Setup Upstart service file
        file=/etc/init/price-tracker.conf
        sudo bash -c 'echo '"'""$upstart_service""'"" > $file"
        sudo service price-tracker restart
        ;;
    $systemd)
        # Setup Systemd service file
        file=`dirname $system`/system/price-tracker.service
        sudo bash -c 'echo '"'""$systemd_service""'"" > $file"
        sudo systemctl daemon-reload
        sudo systemctl restart price-tracker
        sudo systemctl enable price-tracker
        ;;
esac

echo '==> Done !'
