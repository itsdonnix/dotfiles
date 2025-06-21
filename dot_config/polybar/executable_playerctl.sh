#!/usr/bin/env bash

# Enable or disable buttons (true for enabled, false for disabled)
enable_buttons=false

# Fetch player status
playerctlstatus=$(playerctl status 2> /dev/null)

# Initialize the play/pause button variable
play_pause_button=""

# If no player is playing, return empty
if [[ $playerctlstatus == "" ]]; then
  echo ""
elif [[ $playerctlstatus =~ "Playing" ]]; then
  # If buttons are enabled, show the play/pause button for playing state
  if $enable_buttons; then
    play_pause_button="%{A1:playerctl pause:}%{A}"
  fi
else
  # If buttons are enabled, show the play/pause button for paused state
  if $enable_buttons; then
    play_pause_button="%{A1:playerctl play:}%{A}"
  fi
fi

# Initialize previous and next buttons
prev_button=""
next_button=""

# Show the previous and next buttons only if enabled
if $enable_buttons; then
  prev_button="%{A1:playerctl previous:}󰒮%{A}"
  next_button="%{A1:playerctl next:}󰒭%{A}"
fi

# Get the metadata for the current song
title=$(playerctl metadata xesam:title)
artist=$(playerctl metadata xesam:artist)

# Get the current position (in seconds) and total length (in seconds)
current_position=$(playerctl position 2> /dev/null)
total_length=$(playerctl metadata mpris:length 2> /dev/null)

# Check if the values are valid numbers
if [[ ! "$current_position" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  current_position=0
fi

if [[ ! "$total_length" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  total_length=0
fi

# Format the current position and total length to mm:ss format
current_position_minutes=$(echo "$current_position / 60" | bc)
current_position_seconds=$(echo "$current_position % 60 / 1" | bc)
total_length_minutes=$(echo "$total_length / 60000000" | bc)  # convert to seconds
total_length_seconds=$(echo "$total_length % 60" | bc)  # converting mpris:length to seconds

# Format minutes and seconds to always show two digits (e.g., 05 instead of 5)
current_position_formatted=$(printf "%02d:%02d" $current_position_minutes $current_position_seconds)
total_length_formatted=$(printf "%02d:%02d" $total_length_minutes $total_length_seconds)

# Combine the controls if enabled, otherwise leave them empty
controls="$prev_button  $play_pause_button  $next_button"

# Output the song info with current position, total length, and optionally the controls
if $enable_buttons; then
  echo "  $title by $artist -- $current_position_formatted / $total_length_formatted $controls"
else
  echo "  $title by $artist -- $current_position_formatted / $total_length_formatted"
fi

