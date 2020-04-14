#!/usr/bin/env bash
set -e

# Updating and Upgrading dependencies
echo "Installing vim, screen and git -- The basics."
sudo apt-get update -y -qq > /dev/null
sudo apt-get upgrade -y -qq > /dev/null
sudo apt-get install -y vim screen git

echo "Installing ruby and nginx"
sudo apt-get update

sudo apt-get install -y build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev libpq-dev ruby ruby-dev
sudo apt-get install -y nginx apache2-utils

sudo gem install bundler --no-rdoc --no-ri

echo "Installing pact broker"
git clone https://github.com/pact-foundation/pact_broker
sudo cp -r pact_broker/example /usr/local/pact_broker
sudo rm -r /usr/local/pact_broker/basic_auth

sudo adduser pact --disabled-password --system
sudo chown -R pact /usr/local/pact_broker
