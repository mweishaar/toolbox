#!/bin/bash

TITLE=`echo $1 |cut -f1 -d.`

nice -19 HandBrakeCLI -i "$1" -o "$TITLE.m4v" --preset="Apple 2160p60 4K HEVC Surround" --subtitle scan -F 2

#$HANDBRAKE_CLI -i "$SRC/$FILE" -o "$DEST/$filename.$DEST_EXT" --preset="$HB_PRESET" --subtitle scan -F 2>> "$LOG"
