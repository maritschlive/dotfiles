#!/usr/bin/env bash

STATE_FILE="$HOME/.config/hypr/sunset_status"
PID_FILE="/tmp/hyprsunset-daemon.pid"

STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "auto")
if [ "$STATE" = "off" ]; then
    echo "auto" > "$STATE_FILE"
else
    echo "off" > "$STATE_FILE"
fi

# Signal daemon to update immediately
if [ -f "$PID_FILE" ]; then
    daemon_pid=$(cat "$PID_FILE")
    kill -USR1 "$daemon_pid" 2>/dev/null
fi

# Signal Waybar to refresh custom/sunset module
pkill -RTMIN+8 waybar 2>/dev/null
