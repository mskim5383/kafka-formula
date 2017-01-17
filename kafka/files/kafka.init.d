#!/bin/bash

#
# Kafka
#
# chkconfig: 2346 90 8
# description: kafka

KAFKA_HOME=/usr
KAFKA_USER=kafka
KAFKA_SCRIPT={{ alt_home }}/bin/kafka-server-start.sh
KAFKA_STOP_SCRIPT={{ alt_home }}/bin/kafka-server-stop.sh
KAFKA_CONFIG={{ alt_config }}/server.properties
KAFKA_CONSOLE_LOG=/var/log/kafka/console.log



prog=kafka
DESC="kafka daemon"

RETVAL=0
STARTUP_WAIT=30
SHUTDOWN_WAIT=30



# Source function library.
. /etc/init.d/functions

start() {
        echo -n $"Starting $prog: "

        PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')

        if [ ! -z "$PIDS" ]; then
              echo "$prog is running (pid $PIDS)"
              return 1
        fi

        # Run daemon
        cd $KAFKA_HOME
        sh $KAFKA_SCRIPT -daemon $KAFKA_CONFIG 2>&1 &
        RETVAL=$?

        success
        echo
        touch /var/lock/subsys/kafka
        return $RETVAL
}


stop() {
        echo -n $"Stopping $prog: "

        sh $KAFKA_STOP_SCRIPT

        rm -f /var/lock/subsys/kafka
        success
        echo
}

reload() {
        stop
        start
}

restart() {
        stop
        start
}

status() {
        PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')

        if [ -z "$PIDS" ]; then
              echo "$prog is not running"
              return 3
        else 
              echo "$prog is running (pid $PIDS)"
              return 0
        fi
}

case "$1" in
start)
        start
        ;;

stop)
        stop
        ;;

reload)
        reload
        ;;

restart)
        restart
        ;;

status)
        status
        ;;
*)

echo $"Usage: $0 {start|stop|reload|restart|status}"
exit 1
esac
  
exit $?
