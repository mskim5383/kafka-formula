#!/bin/bash

SERVER_START_SCRIPT=/usr/bin/kafka-server-start
SERVER_STOP_SCRIPT=/usr/bin/kafka-server-stop
SERVER_PROPERTY=/etc/kafka/server.properties
RETVAL=0

start() {
  ${SERVER_START_SCRIPT} -daemon ${SERVER_PROPERTY}
  RETVAL=$?
  echo
  return $RETVAL
}

stop() {
  ${SERVER_STOP_SCRIPT}
  RETVAL=$?
  sleep 5
  echo
  return $RETVAL
}

restart() {
  stop
  start
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  *)
    echo $"Usage: $0 {start|stop|restart}"
    exit 1
esac

exit $RETVAL
