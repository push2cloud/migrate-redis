#!/bin/bash
trap exit INT

exit () {
  kill ${PID7000}
  kill ${PID7001}
}



redis-server --port 7000 --requirepass 'foobar' --dir ./test/7000 &
PID7000=$?
redis-server --port 7001 --requirepass 'foobar' --dir ./test/7001 &
PID7001=$?

while : ; do
  sleep 1
done
