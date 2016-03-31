#!/bin/bash
# Run first time through to setup the environment variables, example data, and start the services 
echo '*** MAKE SURE YOU RUN THIS ONLY ONCE ***'

cd ~/pipeline

echo '...Retrieving Latest Updates From Github...'
git reset --hard && git pull

echo '...Configuring Services Before Starting...'
$SCRIPTS_HOME/config-services-before-starting.sh

echo '...Start All Services...'
$SCRIPTS_HOME/start-all-services.sh

echo '...Create Examples Data Sources...'
$SCRIPTS_HOME/create-example-datasources.sh

echo '...Show Exported Variables...'
export

echo '...Show Running Java Processes...'
jps -l

echo '.......................'
echo '...    ALL DONE!    ...'
echo '.......................'
