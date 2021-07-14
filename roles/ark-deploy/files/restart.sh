#!/bin/bash
# Necessary variables.
instance=$1

now=`date +"%Y-%m-%d_%H%M%S"`
# How many minutes to delay server restart.
delay=20

# Announce every 60 seconds for shutdown.
# sudo arkmanager rconcmd @extinction "broadcast Testing rcon broadcast"
until [ $delay == 0 ]
do
  # Eval if people are offline, then exit loop and begin restart sequence.
  arkmanager rconcmd @aberration listplayers | grep -e "No Players Connected"
  if [ $? -eq 0 ]; then
    break;
  fi

  # Notify players that the server will reboot.
  arkmanager rconcmd $instance "broadcast Server Restart in $delay minutes. Please get to a safe location and log out. Server will automatically restart sooner if everyone exits."

  # Decrement delay.
  ((delay--))

  # Wait 60 seconds and repeat.
  sleep 60
done

arkmanager restart $instance --safe --saveworld --backup
