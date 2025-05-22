#!/bin/bash

# Function to send a notification
send_notification() {
  local message=$1
  local id=$(notify-send --expire-time=1000 --replace-id=999 "$message" | grep -oP 'id=\K\d+')
  # Store the notification ID for the next iteration
  echo $id >/tmp/last_notification_id
}

# Function to clear the last notification
clear_last_notification() {
  local last_id=$(cat /tmp/last_notification_id 2>/dev/null)
  if [ -n "$last_id" ]; then
    dbus-send --print-reply=literal --dest=org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.Notifications.CloseNotification int32:$last_id
  fi
}

# Clear the last notification before sending a new one
clear_last_notification

# Send the new notification
brightness=$(brightnessctl g)

send_notification "Brightness: $brightness"
