start on started system-services
stop on runlevel [016]

respawn

exec /usr/local/bin/fancontrol_conf.sh
