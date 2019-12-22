#!/usr/bin/env bash

pid=`ps -ef | grep java | grep -v grep | awk '{ print $2}'`
if [ -n "$pid" ]
then
	kill -9  $pid
fi
echo "start weighbridgeCloudService-0.0.1-SNAPSHOT jar...."
 java -XX:ErrorFile=/home/error/error.log -jar weighbridgeCloudService-0.0.1-SNAPSHOT.jar  --spring.profiles.active=weighbridgeCloudService-dev


