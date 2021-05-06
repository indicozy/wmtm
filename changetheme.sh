#! /bin/bash

path=~/sway-dotfiles-script
cd $path
folder=($1)
if [ $# -eq 1 ]
then
	if [ -f "themeNumber.txt" ]
	then
		 now=$(cat "themeNumber.txt")
	else 
		now=0
		echo "0" > "themeNumber.txt"
	fi
	
	if ! [[ "$now" =~ ^[0-9]+$ ]]
	then
		now=0
	fi

	if [ "$folder" == "next" ]
	then
		folder=$((now+1))
	elif [ "$folder" == "prev" ]
	then
		folder=$((now-1))
	fi

	cd $path/configs
	themes=($(ls -d */))
	if [[ "$folder" =~ ^[0-9]+$ || "$folder" -eq -1 ]]
    then 
		echo "$(( (( (( folder + ${#themes[@]} )) % ${#themes[@]}  )) ))" > "../themeNumber.txt"
		folder=${themes[(( (( folder - 1 + ${#themes[@]} )) % ${#themes[@]}  ))]}
	fi

	if [ -d "$folder" ]
	then
		cd $folder/config
		array=($(ls -d *))

		#some move to ~/Documents/Config_backups/
		mkdir -p ~/Documents/sway_configs_saved
		cd ~/Documents/sway_configs_saved
		saved_folders=($(ls -d *))

		for (( i=${#saved_folders[@]}; i>7;i--))
		do
			rm -r old$((i - 1))
			saved_folders=($(ls -d *))
		done	

		for (( i=${#saved_folders[@]}; i>0; i--))
		do
			mv "${saved_folders[$(( i - 1 ))]}" old$i
		done


		cd $path/configs/$folder
		for i in "${array[@]}"
		do
			mkdir -p ~/Documents/sway_configs_saved/latest/$i
			mv --force ~/.config/$i/* ~/Documents/sway_configs_saved/latest/$i/
		done
		
		#copy files from $folder/config to .config
		cp -r config/* ~/.config
		


		# append text to make any sway config to work with this script


		#kill all panel processes
		killall hybridbar nwgbar nwg-menu nwgdmenu nwg-panel nwg-dock nwg-panel-config nwggrid waybar 
		echo "######[Auto-Appended] Theme switch script
set
{
\$layer3			Mod4+Ctrl
\$code			$path/changetheme.sh
}
bindsym
{
	\$layer3+1 exec \$code 1 
	\$layer3+2 exec \$code 2
	\$layer3+3 exec \$code 3 
	\$layer3+4 exec \$code 4 
	\$layer3+5 exec \$code 5 
	\$layer3+6 exec \$code 6 
	\$layer3+7 exec \$code 7 
	\$layer3+8 exec \$code 8 
	\$layer3+9 exec \$code 9
	\$layer3+left exec \$code prev
	\$layer3+right exec \$code next
}
" >> ~/.config/sway/config
		
		#To change this script to work with outher WMs, just change this part of code to reload your WM
		swaymsg reload

		echo "Theme changed to $folder"
		notify-send "Theme changed to $folder" "Enjoy your Sway!"
	else 		
		echo "Wrong Argument, check your config."
		notify-send "Error at Theme Changer" "Wrong Argument, check your config."

	fi
else
	echo "No arguments given."
		notify-send "Error at Theme Changer" "No arguments given."
fi
