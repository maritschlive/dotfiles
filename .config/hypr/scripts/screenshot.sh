#!/bin/bash

# Datei zum Speichern der Startzeit
TIME_FILE="/tmp/screenshot_time"

if [ "$1" == "press" ]; then
    # Startzeit in Millisekunden aufzeichnen
    date +%s%3N > "$TIME_FILE"
elif [ "$1" == "release" ]; then
    if [ ! -f "$TIME_FILE" ]; then
        exit 0
    fi

    START=$(cat "$TIME_FILE")
    END=$(date +%s%3N)
    rm -f "$TIME_FILE"

    DIFF=$((END - START))

    # Wenn die Taste länger als 400ms gehalten wurde -> Vollbild
    if [ $DIFF -gt 400 ]; then
        grim - | wl-copy
        notify-send -t 2000 "Screenshot" "Vollbild in die Zwischenablage kopiert."
    else
        # Sonst -> Bereich auswählen
        # slurp pausiert den Bildschirm, grim nimmt auf
        grim -g "$(slurp)" - | wl-copy
        notify-send -t 2000 "Screenshot" "Bereich in die Zwischenablage kopiert."
    fi
fi
