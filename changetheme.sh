#! /bin/bash
if [ $# -eq 1 ]
then
	cd ~/sway-dotfiles-script/configs
	if [ -d "$1" ]
	then
		cd $1
		cp -r config/* ~/.config
		killall hybridbar
		killall waybar
		swaymsg reload
	fi
else
	echo "No arguments given."

fi

