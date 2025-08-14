#!/bin/bash
filename="screenshot-$(date +%Y%m%d-%H%M%S).png"
grim -g "$(slurp)" - | tee ~/Pictures/"$filename" | wl-copy && \
    notify-send "Screenshot saved to ~/Pictures/$filename and copied to clipboard"
