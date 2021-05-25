#! /bin/bash
# Script for changing themes of sway-dotfiles-script
# Developed and maintained by indicozy
# ver: 1.0

path=~/.sway-dotfiles-script
save_path=~/Documents/sway_configs_saved

function checksave () {
	now=0
	if [[ $(cat $path/system/themeNumber.txt ) =~ ^[0-9]+$ ]]; then
		 now=$(cat $path/system/themeNumber.txt)
	fi
}

function checkNextPrev (){
	case $folder in
		next) folder=$((now+1));;
		prev) folder=$((now-1));;
	esac
}

function checkNum (){
	local themes=($(ls -d $path/configs/*/))
	local themes=(${themes[*]/%\/})
	local themes=(${themes[*]/*\/})

	if [[ "$folder" =~ ^[0-9]+$ || "$folder" -eq -1 ]]
    then 
		folder=${themes[(( (folder + ${#themes[@]} - 1) % ${#themes[@]} ))]}
	fi
	#Updates the themeNumber.txt
	for (( i = 0; i < ${#themes[@]}; i++ )); do
		if [[ "$folder" = "${themes[$i]}" ]]; then
			echo "$(( $i + 1 ))" > "$path/system/themeNumber.txt"
		fi
	done
}

function copyToConfig () { #!Note think about adding rules and customization to copying to config
	#parse which folder are in the theme
	local theme_folders=($(ls -d $path/configs/$folder/config/*/))
	local theme_folders=(${theme_folders[*]/%\/})
	local theme_folders=(${theme_folders[*]/*\/})

	# local executives=($(ls $path/customization/*/index.sh))
	for i in ${theme_folders[@]}; do
		#if there is a rule for a specific app, then use its script
		if [ -f $path/customization/$i/index.sh ]; then
			eval $path/customization/$i/index.sh $path $folder
			#if not, just copy-paste from the $folder's config
		else
			cp -r $path/configs/$folder/config/$i ~/.config
		fi
	done
}

function killAllProcesses () {
	#kill all panel processes
	killall $(cat $path/system/killprocesses.txt) 2> /dev/null
}


function goback () {
	if ! [[ -d $save_path/old ]]; then
		return 1
	fi

	prepareFolders new

	prepareFolders movedBack

	moveBackupConfig $save_path/movedBack move

	moveLatestBack #function

	sortOld #function

	return 0
}

function sortOld () {
	local oldones=($(ls -d $save_path/old*/ ))
	local oldones=(${oldones[*]/%\/})

	for (( j=0; j<${#oldones[@]}; j++ ))
	do
		mv ${oldones[$j]} $save_path/old$(( j + 1 )) 
	done
	mv $save_path/old1 $save_path/old
}

function moveLatestBack () {
	cp -r $save_path/old/* ~/.config/
	mv $save_path/old $save_path/new
}

function backupConfig () {
		prepareFolders backup
		moveBackupConfig $save_path/backup copy
}

function moveBackupConfig {
	local backupfolders=($(cat $path/system/configFolders.txt))
	mkdir -p $1
	for i in "${backupfolders[@]}"; do
		mkdir -p $1/$i 
		case $2 in
			move) mv  ~/.config/$i/* $1/$i/ ;;
			copy| *) cp -r ~/.config/$i/* $1/$i/ ;;
		esac
	done
}

function prepareFolders {
	local backupones=($(ls -d $save_path/$1*/ ))
	local backupones=(${backupones[*]/%\/})

	for (( j=${#backupones[@]}; j>7; j-- )); do
		rm -r ${backupones[ (( j - 1 ))]} 
	done

	for (( i=${#backupones[@]}; i>0; i-- )); do
		mv ${backupones[(( i - 1 ))]} $save_path/$1$(( i + 1 )) 2> /dev/null
	done
}

function customizeConfig {
	zenity_text='zenity --list --title="Theme Switcher" --text="Choose what to config" --width=300 --height=300 --column="Section"'
	local zenity_array=""
	zenity_array+="\\ "
	local folderNumber=($(ls -d $path/customization/sway/*))
	local folderNumber=(${folderNumber[*]/%\/})
	local folderNumber=(${folderNumber[*]/*\/})

	for (( i=0; i<${#folderNumber[@]}; i++ ))
	do
		zenity_array+="${folderNumber[i]} "
		if ! [ "$(( $i + 1 ))" -eq ${#folderNumber[@]} ]; then
		zenity_array+="\\ "
			fi
	done
	zenity_text+=" $zenity_array"
	folder="customize"
	changeFile=($(eval $zenity_text))
	if [[ "$changeFile" = "" ]]; then
		runZenity 
		exit
	else
		exec $VISUAL $path/customization/sway/$changeFile
	fi
	
}

function wordCheck () {
	#This part of code is a bit messy, sorry for that (past indicozy)
	#working with $folder
	checksave #function
	checkNextPrev #function
	checkNum #function
	
	if [ "$folder" == "fuck" ]; then
		echo "Hey, it's you messed that up, don't blame me for that. Or send an issue to github.com/indicozy"
		notify-send "Hey, it's you messed that up, don't blame me for that." "Or send an issue to github.com/indicozy"

	elif [ "$folder" == "save" ]; then
		backupConfig #function
		echo "Files saved to $save_path/backup"
		notify-send "Config saved!" "Folder is located at: $save_path/backup"
	elif [ "$folder" == "fuckgoback" -o "$folder" == "goback" ]; then
		if goback; then
			swaymsg reload
			echo "Back to the previous theme from history."
			notify-send "Back to the previous theme." "Be careful next time"
		else
			echo "[Error] No older folder found"
			notify-send "Error at Theme Changer" "No older folder found"
		fi
	elif [ "$folder" == "customize" ]; then
		customizeConfig	
		if zenity --question --title="Reload?" --text="Do you want to reload config?" --width=300 --height=300; then
			$path/install.sh $now
		fi
	elif [ -d "$path/configs/$folder" ]; then
			prepareFolders old
			moveBackupConfig $save_path/old move
			copyToConfig #function
			killAllProcesses #function	
		#To change this script to work with outher WMs, just change this part of code to reload your WM
			swaymsg reload

			echo "Theme changed to $folder"
			notify-send "Theme changed to $folder" "Enjoy your Sway!"
	else
			echo "Wrong Argument, check your config."
			notify-send "Error at Theme Changer" "Wrong Argument, check your config."
		fi
}

function runZenity () {
	zenity_text='zenity --list --title="Theme Switcher" --text="Choose your theme" --width=300 --height=300 --column="Id" --column="Theme"'
	local zenity_array=""
	zenity_array+="\\ "
	zenity_array+="prev 'Go to the previous theme' \\ "
	zenity_array+="next 'Go to the next theme' \\ "
	zenity_array+="save 'Save your config' \\ "
	zenity_array+="goback 'Back to previous config' \\ "
	zenity_array+="customize 'Edit your config' \\ "

	local folderNumber=($(ls -d $path/configs/*/))
	local folderNumber=(${folderNumber[*]/%\/})
	local folderNumber=(${folderNumber[*]/*\/})

	for (( i=0; i<${#folderNumber[@]}; i++ ))
	do
		zenity_array+="$(( i + 1 )) " 
		zenity_array+="${folderNumber[i]} "
		if ! [ "$(( $i + 1 ))" -eq ${#folderNumber[@]} ]
		then
		zenity_array+="\\ "
			fi
	done
	zenity_text+=" $zenity_array"
	folder=($(eval $zenity_text))
	if [[ "$folder" != "" ]]; then
		wordCheck
	fi
}


##### MAIN
if [[ "$path" != *sway-dotfiles-script ]]; then
	echo "Error: Wrong path specified! Please check that the script wasa launched from the proper folder."
	notify-send "Error: Wrong path specified!" "Please check that the script wasa launched from the proper folder."
	exit
fi
cd $path
folder=($1)
case $# in
	0)
		runZenity;;
	1)
		wordCheck;;
	*) 
		echo "Given more than one argument. Please check your config"
		notify-send "Given more than one argument" "Please check your config";;
esac
