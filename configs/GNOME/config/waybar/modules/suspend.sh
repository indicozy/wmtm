#!/bin/bash

zenity --question \
	--text "Are you sure you want to suspend?" \
	--window-icon "warning" \
	--height 100 \
	--width 200

if [[ $? -eq 0 ]]; then
	systemctl suspend; swaylock
fi
