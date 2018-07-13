#!/bin/bash

PATRONEOSROOT=/opt/patroneos
PIDFILE=/var/run/patroneosd.pid

if [ -f $PIDFILE ]; then
   echo "PID file $FILE exists, restarting"
   kill -SIGTERM `cat $PIDFILE`
fi

nohup $PATRONEOSROOT/patroneosd -configFile $PATRONEOSROOT/config.json > /var/log/patroneosd.log 2>&1 & echo $! > $PIDFILE

echo "Started patroneosd ($(cat $PIDFILE)) and redirecting output to /var/log/patroneosd.log"
