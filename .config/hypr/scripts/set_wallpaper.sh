#!/usr/bin/env bash
set -e

# Target wallpaper file
WALLPAPER="$1"

# Default folder to open in file picker if no file given
DEFAULT_DIR="$HOME/Pictures"
if [ ! -d "$DEFAULT_DIR" ]; then
    DEFAULT_DIR="$HOME"
fi

# If --pick or no argument passed, open GUI file selector
if [ -z "$WALLPAPER" ] || [ "$WALLPAPER" = "--pick" ] || [ "$WALLPAPER" = "-p" ]; then
    if command -v zenity >/dev/null 2>&1; then
        WALLPAPER=$(zenity --file-selection \
            --filename="$DEFAULT_DIR/" \
            --title="Hintergrundbild auswählen" \
            --file-filter="Bilder (*.jpg *.png *.jpeg *.webp) | *.jpg *.png *.jpeg *.webp *.JPG *.PNG *.JPEG *.WEBP")
    fi
fi

# Check if user cancelled or file doesn't exist
if [ -z "$WALLPAPER" ]; then
    echo "Kein Hintergrundbild ausgewählt."
    exit 0
fi

if [ ! -f "$WALLPAPER" ]; then
    echo "Fehler: Datei '$WALLPAPER' existiert nicht!" >&2
    exit 1
fi

echo "Setting wallpaper: $WALLPAPER"

# 1. Ensure awww-daemon is running
if ! pgrep -x awww-daemon >/dev/null; then
    hyprctl dispatch exec "awww-daemon" 2>/dev/null || awww-daemon &
    sleep 0.3
fi

# 2. Apply wallpaper with smooth transition using awww
if command -v awww >/dev/null 2>&1; then
    awww img "$WALLPAPER" --transition-type wipe --transition-step 90 2>/dev/null || awww img "$WALLPAPER"
fi

# 3. Generate dynamic system color palette with Matugen
if command -v matugen >/dev/null 2>&1; then
    matugen image "$WALLPAPER" --source-color-index 0
fi

# 4. Notify user
if command -v notify-send >/dev/null 2>&1; then
    FILENAME=$(basename "$WALLPAPER")
    notify-send -i "$WALLPAPER" "Hintergrund & Farbschema" "Neues Wallpaper und Systemfarben angewendet:\n$FILENAME"
fi

echo "Successfully updated wallpaper and system color scheme!"
