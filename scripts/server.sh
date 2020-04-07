#!/bin/bash
set -e

sudo cp /tmp/nginx.conf /etc/nginx/sites-available/default
sudo cp /tmp/rack.conf /usr/local/pact_broker/config.ru
sudo cp /tmp/Gemfile /usr/local/pact_broker/Gemfile
sudo cp /tmp/pact-broker.sh /usr/local/bin/

sudo chmod 755 /usr/local/bin/pact-broker.sh

cd /usr/local/pact_broker
sudo -H -u pact bash -c "bundle config set path 'vendor/bundle'"
sudo -H -u pact bash -c "bundle config set without 'development test'"
sudo -H -u pact bash -c 'bundle'

sudo mkdir /etc/pact_broker
sudo mv /tmp/postgres_vars /etc/pact_broker/config
sudo chmod 755 /etc/pact_broker/config
. /etc/pact_broker/config
bundle exec sequel -m ~/pact_broker/db/migrations/ $DB_URL

