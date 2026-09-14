#!/usr/bin/env bash

# Find primary monitor (built-in monitor like eDP, LVDS, DSI)
PRIMARY=$(hyprctl monitors all -j | jq -r '.[] | select(.name | startswith("eDP") or startswith("LVDS") or startswith("DSI")) | .name' | head -n 1)

# If no built-in screen matches, use the one with ID 0
if [ -z "$PRIMARY" ]; then
    PRIMARY=$(hyprctl monitors all -j | jq -r '.[] | select(.id == 0) | .name' | head -n 1)
fi

if [ -z "$PRIMARY" ]; then
    notify-send -t 3000 "Screen Mirroring" "Error: Could not identify primary monitor."
    exit 1
fi

# Find all external monitors (not equal to PRIMARY)
EXTERNAL_MONITORS=$(hyprctl monitors all -j | jq -r ".[] | select(.name != \"$PRIMARY\") | .name")

if [ -z "$EXTERNAL_MONITORS" ]; then
    notify-send -t 3000 "Screen Mirroring" "No external monitors connected."
    exit 0
fi

# Check if any external monitor is currently mirroring something
IS_MIRRORING=false
for monitor in $EXTERNAL_MONITORS; do
    mirror_of=$(hyprctl monitors all -j | jq -r ".[] | select(.name == \"$monitor\") | .mirrorOf")
    if [ "$mirror_of" != "none" ] && [ -n "$mirror_of" ]; then
        IS_MIRRORING=true
        break
    fi
done

if [ "$IS_MIRRORING" = true ]; then
    # Disable mirroring: restore all external monitors to extended mode
    for monitor in $EXTERNAL_MONITORS; do
        hyprctl keyword monitor "$monitor,preferred,auto,auto"
    done
    notify-send -t 3000 "Screen Mirroring" "Mirroring disabled (Extended Desktop)"
else
    # Enable mirroring: mirror all external monitors to primary
    for monitor in $EXTERNAL_MONITORS; do
        hyprctl keyword monitor "$monitor,preferred,auto,auto,mirror,$PRIMARY"
    done
    notify-send -t 3000 "Screen Mirroring" "Mirroring enabled ($PRIMARY -> External)"
fi
