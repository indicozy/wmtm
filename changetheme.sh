#! /bin/bash

path=~/Apps/git/sway-advanced-config

function checksave () {
	cd $path
if [ -f "themeNumber.txt" ]
	then
		 now=$(cat "themeNumber.txt")
	else 
		now=0
	fi
	
	if ! [[ "$now" =~ ^[0-9]+$ ]]
	then
		now=0
	fi
	return $now
}

function checkNextPrev (){
	if [ "$folder" == "next" ]
	then
		folder=$((now+1))
	elif [ "$folder" == "prev" ]
	then
		folder=$((now-1))
	fi
}

function checkNum (){
	cd $path/configs
	themes=($(ls -d */))
	if [[ "$folder" =~ ^[0-9]+$ || "$folder" -eq -1 ]]
    then 
		echo "$(( (( (( folder + ${#themes[@]} )) % ${#themes[@]}  )) ))" > "$path/themeNumber.txt"
		folder=${themes[(( (( folder - 1 + ${#themes[@]} )) % ${#themes[@]}  ))]}
	fi
	cd $path
}

function findFolder () {
	cd $path/configs
	if [ -d "$folder" ]
	then
		echo 1
	else
		echo 0
	fi
	cd $path
}

function prepareHistoryFolders () {
	
	#move to ~/Documents/Config_backups/
	mkdir -p ~/Documents/sway_configs_saved
	cd ~/Documents/sway_configs_saved
	saved_folders=($(ls -d old*))
		for (( i=${#saved_folders[@]}; i>0; i--))
		do
			mv ~/Documents/sway_configs_saved/"${saved_folders[$(( i - 1 ))]}" ~/Documents/sway_configs_saved/old$(( i + 1))
		done
		if [ -d latest ]
		then
			mv ~/Documents/sway_configs_saved/latest ~/Documents/sway_configs_saved/old1
	saved_folders=($(ls -d old*))
		fi
		for (( i=${#saved_folders[@]}; i>7; i--)) #removes old folers up to 7+1 (1 is newly created) folders
		do
			rm -r ~/Documents/sway_configs_saved/${saved_folders[(($i - 1))]}
		done
		cd $path
}

function moveToHistory () {
		mkdir -p ~/Documents/sway_configs_saved/latest
		cd $path/configs/$folder/config
		array=($(ls -d *))
		for i in "${array[@]}"
		do
			mkdir -p ~/Documents/sway_configs_saved/latest/$i
			mv --force ~/.config/$i/* ~/Documents/sway_configs_saved/latest/$i/
		done
		cd $path
} 

function copyToConfig () {
		#copy files from $folder/config to .config
	cd $path/configs/$folder
			cp -r $path/configs/$folder/config/* ~/.config
	cd $path
}

function killAllProcesses () {
	#kill all panel processes
	killall hybridbar nwgbar nwg-menu nwgdmenu nwg-panel nwg-dock nwg-panel-config nwggrid waybar 
	cd $path
}

function autoAppend () {
			# append text to make any sway config to work with this script
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
cd $path
}

function goback () {
	updateSaved

	cd ~/Documents/sway_configs_saved
	if [[ -d latest ]]
	then

		if [ "${#newones[@]}" -gt "0" ]
		then
			moveNewOnes
			cleanNewOnes
		fi
		
		appendSavedFromConfig
		cleanSavedFromConfig
		saveFromConfig
		
		moveLatestBack #function

		addNew

			sortOld #function
	else
		echo "No older folders found"
		notify-send "No older folders found"
	fi
	cd $path
}

function moveNewOnes () {
	
	for (( j=${#newones[@]}; j>0; j-- ))
	do
		mv ~/Documents/sway_configs_saved/${newones[$(( j - 1 ))]} ~/Documents/sway_configs_saved/new$(( j + 1)) 
	done
	updateSaved
	cd $path
}

function sortOld () {
	for (( j=0; j<${#oldones[@]}; j++ ))
	do
		mv ~/Documents/sway_configs_saved/${oldones[$j]} ~/Documents/sway_configs_saved/old$j 
	done
	mv ~/Documents/sway_configs_saved/old0 ~/Documents/sway_configs_saved/latest
	updateSaved
	cd $path
}

function moveLatestBack () {
	cd ~/Documents/sway_configs_saved
	if [ -d latest ]
	then
		cp -r ~/Documents/sway_configs_saved/latest/* ~/.config/
	else
		echo "No latest folder found"
		notify-send "No latest folder found"
	fi
	cd $path
}


function cleanNewOnes () { #add
	for (( j=${#newones[@]}; j>7; j-- ))
	do 
		rm -r ~/Documents/sway_configs_saved/${newones[(( j - 1 ))]} 
	done
	updateSaved
	cd $path
}

function addNew () {
	cd ~/Documents/sway_configs_saved
	if [ -d latest ]
	then
		mv ~/Documents/sway_configs_saved/latest ~/Documents/sway_configs_saved/new1
	else
		echo "No latest folder found"
		notify-send "No latest folder found"
	fi
	updateSaved
	cd $path
}

function saveFromConfig () {
	cd ~/Documents/sway_configs_saved
	if [ -d latest ]
	then
		cd ~/Documents/sway_configs_saved/latest
		array=($(ls -d *))
		mkdir ~/Documents/sway_configs_saved/movedBack1
		for i in "${array[@]}"
		do
			mkdir -p ~/Documents/sway_configs_saved/movedBack1/$i
			mv --force ~/.config/$i/* ~/Documents/sway_configs_saved/movedBack1/$i/
		done
	else
		echo "No latest folder found"
		notify-send "No latest folder found"
	fi
	updateSaved
	cd $path
}

function appendSavedFromConfig () {
	for (( i=${#movedBackOnes[@]}; i>0; i-- ))
	do
		mv ~/Documents/sway_configs_saved/${movedBackOnes[(( i - 1 ))]} ~/Documents/sway_configs_saved/movedBack$(( i + 1 ))
	done
	updateSaved
	cd $path
}

function cleanSavedFromConfig () {
	for (( j=${#movedBackOnes[@]}; j>7; j-- ))
	do
		rm -r ~/Documents/sway_configs_saved/${movedBackOnes[ (( j - 1 ))]}
	done
	updateSaved
	cd $path
}

function updateSaved () {
	cd ~/Documents/sway_configs_saved
	oldones=($(ls -d old*))  
	newones=($(ls -d new*))
	movedBackOnes=($(ls -d movedBack*))
	backupones=($(ls -d backup*/))
	cd $path
}

function backupConfig () {
	updateSaved
	cd $path
		appendBackupConfig
		cleanBackupConfig
		moveBackupConfig
	cd $path
}

function moveBackupConfig () {
	cd ~/Documents/sway_configs_saved/
	backupfolders=(hybridbar alacritty mako nwg-dock nwg-launchers nwg-panel rofi sway swaylock waybar wlogout zathura) 
	mkdir ~/Documents/sway_configs_saved/backup1
	for i in "${backupfolders[@]}"
	do
		mkdir -p ~/Documents/sway_configs_saved/backup1/$i
		cp -r ~/.config/$i/* ~/Documents/sway_configs_saved/backup1/$i/
	done
	cd $path
}

function appendBackupConfig () {
	for (( i=${#backupones[@]}; i>0; i-- ))
	do
		mv ~/Documents/sway_configs_saved/${backupones[(( i - 1 ))]} ~/Documents/sway_configs_saved/backup$(( i + 1 ))
	done
	updateSaved
	cd $path
}

function cleanBackupConfig () {
	for (( j=${#backupones[@]}; j>7; j-- ))
	do
		rm -r ~/Documents/sway_configs_saved/${backupones[ (( j - 1 ))]}
	done
	updateSaved
	cd $path
}

function wordCheck () {
	if [ "$folder" == "fuck" ]
	then
		echo "Hey, it's you messed that up, don't blame me for that. Or send an issue to github.com/indicozy"
		notify-send "Hey, it's you messed that up, don't blame me for that." "Or send an issue to github.com/indicozy"
	elif [ "$folder" == "save" ]
	then
		backupConfig #function
		echo "Files saved to ~/Documents/sway_configs_saved/backup1"
		notify-send "Config saved!" "Folder is located at: ~/Documents/sway_configs_saved/backup1"
	elif [ "$folder" == "fuckgoback" -o "$folder" == "goback" ]
	then
		cd ~/Documents/sway_configs_saved
		if [ -d latest ]
		then
			goback #function
			swaymsg reload
			echo "Back to the previous theme from history."
			notify-send "Back to the previous theme." "Be careful next time"
		else
			echo "[Error] No older folder found"
			notify-send "Error at Theme Changer" "No older folder found"
		fi
	elif [ $checker -eq 1 ]
		then
			prepareHistoryFolders #function
			moveToHistory #function
			copyToConfig #function
			autoAppend #function
			killAllProcesses #function	
		
		#To change this script to work with outher WMs, just change this part of code to reload your WM
			swaymsg reload
		#Messages
			echo "Theme changed to $folder"
			notify-send "Theme changed to $folder" "Enjoy your Sway!"
		else
			echo "Wrong Argument, check your config."
			notify-send "Error at Theme Changer" "Wrong Argument, check your config."
		fi
}


# Main function
cd $path
folder=($1)
if [[ "$path" == "/home/$USER" || "$path" == "~"  ]]
then
	echo "bruh, you could've just killed your files, check what you have written first!"
	notify-send "bruh, you could've just killed your files, check what you have written first!"
elif [ $# -eq 0 ]
then
	runZenity

elif [ $# -eq 1 ]
then
	checksave #function
	checkNextPrev #function
	checkNum #function
	checker=$(findFolder)
	wordCheck
else
	echo "No arguments given."
		notify-send "Error at Theme Changer" "No arguments given."
fi
