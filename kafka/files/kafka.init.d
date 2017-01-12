#!/bin/bash

KAFKA_HOME=/usr
KAFKA_USER=kafka
KAFKA_SCRIPT=$KAFKA_HOME/bin/kafka-server-start
KAFKA_CONFIG=/etc/kafka/server.properties
KAFKA_CONSOLE_LOG=/var/log/kafka/console.log



prog=kafka
DESC="kafka daemon"

RETVAL=0
STARTUP_WAIT=30
SHUTDOWN_WAIT=30

KAFKA_PIDFILE=/var/run/kafka/kafka.pid


# Source function library.
. /etc/init.d/functions

start() {
  echo -n $"Starting $prog: "

        # Create pid file
        if [ -f $KAFKA_PIDFILE ]; then
                read ppid < $KAFKA_PIDFILE
                if [ `ps --pid $ppid 2> /dev/null | grep -c $ppid 2> /dev/null` -eq '1' ]; then
                        echo -n "$prog is already running"
                        failure
                        echo
                        return 1
                else
                      rm -f $KAFKA_PIDFILE
                fi
        fi

        rm -f $KAFKA_CONSOLE_LOG
        mkdir -p $(dirname $KAFKA_PIDFILE)
        chown $KAFKA_USER $(dirname $KAFKA_PIDFILE) || true
  
        # Run daemon
        cd $KAFKA_HOME
        nohup sh $KAFKA_SCRIPT $KAFKA_CONFIG 2>&1 >> $KAFKA_CONSOLE_LOG 2>&1 &
        PID=$!
        RETVAL=$?
        echo $PID > $KAFKA_PIDFILE

  
        success
        echo
        [ $RETVAL -eq 0 ] && touch /var/lock/subsys/kafka
        return $RETVAL
}


stop() {
        echo -n $"Stopping $prog: "
        count=0;

        if [ -f $KAFKA_PIDFILE ]; then
                read kpid < $KAFKA_PIDFILE
                let kwait=$SHUTDOWN_WAIT

                # Try issuing SIGTERM
                kill -15 $kpid
                until [ `ps --pid $kpid 2> /dev/null | grep -c $kpid 2> /dev/null` -eq '0' ] || [ $count -gt $kwait ]
                        do
                        sleep 1
                        let count=$count+1;
                done

                if [ $count -gt $kwait ]; then
                        kill -9 $kpid
                fi
        fi

        rm -f /var/lock/subsys/kafka
        rm -f $KAFKA_PIDFILE
        rm -f $KAFKA_CONSOLE_LOG
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
        if [ -f $KAFKA_PIDFILE ]; then
                read ppid < $KAFKA_PIDFILE
                if [ `ps --pid $ppid 2> /dev/null | grep -c $ppid 2> /dev/null` -eq '1' ]; then
                        echo "$prog is running (pid $ppid)"
                        return 0
                else
                      echo "$prog dead but pid file exists"
                        return 1
                fi
        fi
        echo "$prog is not running"
        return 3
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
