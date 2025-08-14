#!/bin/bash
grim - | tee /tmp/shot.png | wl-copy &&
    notify-send "Full screenshot copied to clipboard"
