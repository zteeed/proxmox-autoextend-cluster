#!/bin/sh 
prev_pid=0
while true; do 
  pid=$(ps aux | grep Connect | head -n 1 | awk '{print $2}')
  if [ $prev_pid -eq $pid ]; then
    kill -9 $pid
  else
    prev_pid=$pid
  fi
  sleep 3
done
