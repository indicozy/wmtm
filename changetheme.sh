#! /bin/bash
# Script for changing themes of sway-dotfiles-script
# Developed and maintained by indicozy
# ver: 0.11

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

function copyToConfig () { 
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


function goBack () {
	if ! [[ -d $save_path/old ]]; then
			echo "[Error] No older folder found"
			notify-send "Error at Theme Changer" "No older folder found"
		return 1
	fi

	prepareFolders new
	prepareFolders movedBack
	moveBackupConfig $save_path/movedBack move
	moveLatestBack
	sortOld
	swaymsg reload

	echo "Back to the previous theme from history."
	notify-send "Back to the previous theme." "Be careful next time"

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
		echo "Files saved to $save_path/backup"
		notify-send "Config saved!" "Folder is located at: $save_path/backup"
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
	local backupones=($(ls -d $save_path/$1*/ )) # Wtf is 1??? ah, it's the argument given to the function dummy
	local backupones=(${backupones[*]/%\/})

	for (( j=${#backupones[@]}; j>7; j-- )); do
		rm -r ${backupones[ (( j - 1 ))]} 
	done

	for (( i=${#backupones[@]}; i>0; i-- )); do
		mv ${backupones[(( i - 1 ))]} $save_path/$1$(( i + 1 )) 2> /dev/null
	done
}

function unzipResources {
	if [ -d "$path/configs/$folder/resources/$1" ]; then
		local fileNumber=($(ls -d $path/configs/$folder/resources/$1/* 2> /dev/null))
		local fileNumber=(${fileNumber[*]/*\/})

		local fileNumberNoEnd=(${fileNumber[*]/%\.tar\.?z})
		local fileNumberNoEnd=(${fileNumberNoEnd[*]/%\.zip})

		mkdir -p $2
		for (( i=0; i<${#fileNumber[@]}; i++ )); do
			if ! [ -d "$2/${fileNumberNoEnd[$i]}" ]; then
				if [[ ${fileNumber[$i]} == *".tar"* ]]; then
					echo "Unzipping ${fileNumber[$i]} to $2..."
					tar -xf $path/configs/$folder/resources/$1/${fileNumber[$i]} -C $2 > /dev/null
				elif [[ ${fileNumber[$i]} == *".zip"* ]]; then
					echo "Unzipping ${fileNumber[$i]} to $2..."
					mkdir -p $2
					unzip -d $2/${fileNumberNoEnd[$i]} "$path/configs/$folder/resources/fonts/${fileNumber[$i]}" > /dev/null
				fi
			fi
		done
	fi
}

function prepareResources {
	if ! [ -d "$path/configs/$folder/resources" ]; then
		return 1
	fi
	unzipResources fonts /home/$USER/.local/share/fonts
	unzipResources icons /home/$USER/.icons
	unzipResources themes /home/$USER/.themes
}

function reloadProcesses {
	swaymsg reload
}

function changeTheme {
	if [ -d "$path/configs/$folder" ]; then
		prepareFolders old
		moveBackupConfig $save_path/old move
		prepareResources
		copyToConfig
		killAllProcesses
		reloadProcesses
		echo "Theme changed to $folder"
		notify-send "Theme changed to $folder" "Enjoy your Sway!"
	else
		echo "Wrong Argument, check your config."
		notify-send "Error at Theme Changer" "Wrong Argument, check your config."
	fi
}

function findEditor {
	### Somehow by using a hotkey combination Mod4+Ctrl+Space doesn't work with 'which' and '-v $VISUAL' commands, so I made an alternative script
	### Sorry not sorry, cry your eyes out of my coding solutions
 local finder=(mousepad gedit kwrite sublime-text gvim geany leafpad bluefish atom)
 for i in ${finder[@]}; do
	if [ -f /usr/bin/$i ]; then
		echo $i
		return 0
	fi
 done

 echo error
 return 1
}

function customizeSpecificConfig {
	local zenity_text="zenity --list --title='Theme Switcher' --text='Choose config section' --width=300 --height=300 --column='Section' "
	local textNumber=($(ls -d $path/customization/$1/*.txt 2> /dev/null))
	local textNumber=(${textNumber[*]/%\.txt})
	local textNumber=(${textNumber[*]/*\/})
	
	for i in ${textNumber[@]}; do
		zenity_text+="$i "
	done

	changeFile=($(eval $zenity_text))
	if [[ "$changeFile" = "" ]]; then
		eval $path/changetheme.sh customize
		# exit
	else
		visual_editor=$(findEditor)
		if [[ $visual_editor = error ]]; then
			notify-send "No visual editor found" "You can find your config files in $path/customization"
			echo "No visual editor found, you can find your config files in $path/customization"
			exit
		fi
		eval $visual_editor $path/customization/$1/$changeFile\.txt
		if zenity --question --title="Reload?" --text="Would you like to recompile your config?" --width=300 --height=300; then
			folder=$now
			wordCheck
		fi
	fi
}

function customizeConfig {
	local zenity_text="zenity --list --title='Theme Switcher' --text='Choose config section' --width=300 --height=300 --column='Section' "
		
	local textNumber=($(ls -d $path/customization/*/))
	local textNumber=(${textNumber[*]/%\/})
	local textNumber=(${textNumber[*]/*\/})
	
	for i in ${textNumber[@]}; do
		zenity_text+="$i "
	done

	changeFile=($(eval $zenity_text))

	if [[ "$changeFile" = "" ]]; then
		eval $path/changetheme.sh
		exit 0
        else
                customizeSpecificConfig $changeFile
	fi
}

function  wellFuckMeThen {
		echo "Hey, it's you messed that up, don't blame me for that. Or send an issue to github.com/indicozy"
		notify-send "Hey, it's you messed that up, don't blame me for that." "Or send an issue to github.com/indicozy"
}

function handleFolder {
	#working with $folder, input is number, the output is the folder's name
	checksave #function TODO
	checkNextPrev #function
	checkNum #function
}

function wordCheck () {
	#This part of code is a bit messy, sorry for that (past indicozy)x2

	handleFolder
	
	case $folder in
		fuck) wellFuckMeThen;;
		save) backupConfig;;
		fuckgoback| goback) goBack;;
		customize) customizeConfig;;
		*) changeTheme;;
	esac

}

function runZenity () {
	local zenity_text="zenity --list --title='Theme Switcher' --text='Choose your theme' --width=300 --height=300 --column='Id' --column='Theme' \\
prev 'Go to the previous theme' \\ 
next 'Go to the next theme' \\ 
save 'Save your config' \\
goback 'Back to previous config' \\ 
customize 'Edit your config' \\ "

	local folderNumber=($(ls -d $path/configs/*/))
	local folderNumber=(${folderNumber[*]/%\/})
	local folderNumber=(${folderNumber[*]/*\/})

	# STOPPED HERE
	for (( i=0; i<${#folderNumber[@]}; i++ ))
	do
		zenity_text+="$(( i + 1 )) " 
		zenity_text+="${folderNumber[i]} "
		if ! [ "$(( $i + 1 ))" -eq ${#folderNumber[@]} ]
		then
		zenity_text+="\\ "
			fi
	done
	folder=($(eval $zenity_text))
	if [[ "$folder" != "" ]]; then
		wordCheck
	fi
}


##### MAIN
path=~/.sway-dotfiles-script
save_path=~/Documents/sway_configs_saved

# Some Security check
if [[ "$path" != *sway-dotfiles-script ]]; then # basic foolproof design
	echo "Error: Wrong path specified! Please check that the script was launched from the proper folder."
	notify-send "Error: Wrong path specified!" "Please check that the script was launched from the proper folder."
	exit
fi

folder=($1) # Global variable
case $# in
	0)
		runZenity;;
	1)
		wordCheck;;
	*) 
		echo "Given more than one argument. Please check your config"
		notify-send "Given more than one argument" "Please check your config";;
esac
exit 0
