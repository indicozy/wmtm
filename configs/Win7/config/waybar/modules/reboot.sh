#!/bin/bash

zenity --question \
	--text "Are you sure you want to reboot?" \
	--window-icon "warning" \
	--height 100 \
	--width 200

if [[ $? -eq 0 ]]; then
	shutdown -r now
fi
