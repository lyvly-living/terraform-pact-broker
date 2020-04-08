#!/bin/bash
set -e

sudo cp /tmp/pact-broker.service /lib/systemd/system/pact-broker.service
sudo cp /tmp/nginx.service /lib/systemd/system/nginx.service

sudo touch /var/log/pact-broker.log
sudo chmod 755 /var/log/pact-broker.log
sudo chown pact /var/log/pact-broker.log

echo "Starting Pact Broker"
sudo systemctl enable pact-broker
sudo systemctl start pact-broker

echo "Starting nginx"
sudo systemctl enable nginx
sudo systemctl start nginx
