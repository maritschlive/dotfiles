#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config/hypr"
STATE_FILE="$CONFIG_DIR/sunset_status"
PID_FILE="/tmp/hyprsunset-daemon.pid"
CALC_SCRIPT="$CONFIG_DIR/scripts/hyprsunset-calc.py"

echo "$$" > "$PID_FILE"

# Track hyprsunset process PID
SUNSET_PID=""

cleanup() {
    if [ -n "$SUNSET_PID" ]; then
        kill "$SUNSET_PID" 2>/dev/null
    fi
    pkill -x hyprsunset
    rm -f "$PID_FILE"
    exit 0
}
trap cleanup SIGINT SIGTERM

run_sunset() {
    if [ -z "$SUNSET_PID" ] || ! kill -0 "$SUNSET_PID" 2>/dev/null; then
        pkill -x hyprsunset
        hyprsunset -t 4000 &
        SUNSET_PID=$!
    fi
}

stop_sunset() {
    if [ -n "$SUNSET_PID" ]; then
        kill "$SUNSET_PID" 2>/dev/null
        SUNSET_PID=""
    fi
    pkill -x hyprsunset
}

update() {
    STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "auto")
    
    if [ "$STATE" = "off" ]; then
        stop_sunset
        # Sleep until toggled back on
        sleep infinity &
        wait $!
    else
        # Calculate transition
        read -r current_state seconds_to_next < <(python3 "$CALC_SCRIPT" 2>/dev/null)
        
        # Fallback if calculation fails
        if [ -z "$current_state" ] || [ -z "$seconds_to_next" ]; then
            current_state="day"
            seconds_to_next=3600
        fi
        
        if [ "$current_state" = "night" ]; then
            run_sunset
        else
            stop_sunset
        fi
        
        # Sleep until the next transition
        sleep "$seconds_to_next" &
        wait $!
    fi
}

# Trap USR1 to wake up instantly on toggle
trap update SIGUSR1

while true; do
    update
done
