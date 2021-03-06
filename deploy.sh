#!/bin/bash

#
# This script is executed with TravisCI (see .travis.yml file) on the server using SSH
#
# Required :
# * https://github.com/iron-meteor/iron-cli
# * pm2
#

cd `dirname $0`

printf "`date +%Y-%m-%d` : Trying ...\n" >> deploy.log

if [ ! -e "$HOME/.meteor/meteor" ]; then curl https://install.meteor.com | sed s/--progress-bar/-sL/g | /bin/sh; fi

#iron-meteor
echo "Cheking iron-meteor ..."
if npm list -g --depth=0 | grep iron-meteor
then
	echo "iron-meteor already installed."
else
	echo "Installing iron-meteor ..."
	npm install iron-meteor -g
	echo "Installed iron-meteor !"
fi

#PM2
echo "Cheking PM2 ..."
if npm list -g --depth=0 | grep pm2
then
	echo "PM2 already installed."
else
	echo "Installing PM2 ..."
	npm install pm2 -g
	echo "Installed PM2 !"
fi

## Build
echo "Building ..."
npm run build:prod
echo "Building : done !"

## Install NPM dependencies
echo "Installing NPM dependencies ..."
npm run install:prod
echo "Installed NPM dependencies !"

## Run with pm2
echo "Running PM2 ..."
METEOR_SETTINGS=$(cat config/production/settings.json) pm2 startOrRestart ecosystem.json5 --env production

echo "Deployed successfully !"
printf "`date +%Y-%m-%d` : \n$(git show --name-status)\n\n" >> deploy.log
