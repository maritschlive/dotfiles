#!/usr/bin/env bash

STATE_FILE="$HOME/.config/hypr/sunset_status"
STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "auto")

if [ "$STATE" = "off" ]; then
    echo '{"text": "󰖙", "alt": "disabled", "tooltip": "Night Light: Disabled entirely", "class": "disabled"}'
else
    if pgrep -x "hyprsunset" >/dev/null; then
        echo '{"text": "󰖔", "alt": "active", "tooltip": "Night Light: Active (4000K)", "class": "active"}'
    else
        echo '{"text": "󰖔", "alt": "idle", "tooltip": "Night Light: Idle (Scheduled for sunset)", "class": "idle"}'
    fi
fi
