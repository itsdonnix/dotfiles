#!/usr/bin/env bash

(
  flock 200

  # Check if polybar is installed
  if ! command -v polybar &>/dev/null; then
    echo "Polybar is not installed. Exiting."
    exit 1
  fi

  # Kill all running polybar instances
  killall -q polybar

  while pgrep -u $UID -x polybar >/dev/null; do sleep 0.5; done

  # Get the list of connected monitors using polybar --list-monitors
  MONITORS=$(polybar --list-monitors | cut -d" " -f1 | sed 's/://')

  # Determine the primary monitor
  PRIMARY_MONITOR=$(polybar --list-monitors | grep primary | cut -d" " -f1 | sed 's/://')

  # Initialize TRAY_OUTPUT to an empty value
  TRAY_OUTPUT=""

  # Check if there is any monitor that's not the primary monitor and use that for the tray
  for MONITOR in $MONITORS; do
    if [[ $MONITOR != $PRIMARY_MONITOR ]]; then
      TRAY_OUTPUT=$MONITOR
      break # We use the first non-primary monitor found for the tray
    fi
  done

  # If no non-primary monitor is found, use the primary monitor for the tray
  if [[ -z $TRAY_OUTPUT ]]; then
    TRAY_OUTPUT=$PRIMARY_MONITOR
  fi

  # Launch Polybar on each monitor with appropriate bar name
  for MONITOR in $MONITORS; do
    export MONITOR=$MONITOR
    export TRAY_POSITION=none

    if [[ $MONITOR == $TRAY_OUTPUT ]]; then
      TRAY_POSITION=right
    fi

    polybar --reload main-bar </dev/null >/var/tmp/polybar-$MONITOR.log 2>&1 200>&- &
    disown
  done
) 200>/var/tmp/polybar-launch.lock
