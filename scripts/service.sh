#!/bin/bash
set -e

sudo cp /tmp/pact-broker.service /lib/systemd/system/pact-broker.service
sudo cp /tmp/nginx-upstart.conf /etc/nginx/nginx.conf

sudo touch /var/log/pact-broker.log
sudo chmod 755 /var/log/pact-broker.log
sudo chown pact /var/log/pact-broker.log

echo "Starting Pact Broker"
sudo systemctl enable pact-broker
sudo systemctl start pact-broker

sudo fuser -k 80/tcp
echo "Starting nginx"
sudo start nginx
