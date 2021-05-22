#! /bin/bash
# Script for changing themes of sway-dotfiles-script
# Developed and maintained by indicozy
# ver: 1.0

path=~/.sway-dotfiles-script
save_path=~/Documents/sway_configs_saved

function checksave () {
	now=0
	if [[ $(cat $path/system/themeNumber.txt) =~ ^[0-9]+$ ]] && [[ -s $path/themeNumber.txt ]]; then
		 now=$(cat $path/system/themeNumber.txt)
	fi
}

function checkNextPrev (){
	case $folder in
		next) folder=$((now+1));;
		prev) folder=$((now-1));;
	esac
}

function checkNum (){ #later
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
			echo "$(( $i + 1 ))" > "$path/themeNumber.txt"
		fi
	done
}

function copyToConfig () {
	#copy files from $folder/config to .config
	cp -r $path/configs/$folder/config/* ~/.config
}

function killAllProcesses () {
	#kill all panel processes
	killall $(cat $path/system/killprocesses.txt) 2> /dev/null
	cd $path
}

function autoAppend () {
			# append text to make any sway config to work with this script
	echo "######[Auto-Appended] Theme switch script

bindsym
{
	Mod4+Ctrl+1 exec $path/changetheme.sh 1 
	Mod4+Ctrl+2 exec $path/changetheme.sh 2
	Mod4+Ctrl+3 exec $path/changetheme.sh 3 
	Mod4+Ctrl+4 exec $path/changetheme.sh 4 
	Mod4+Ctrl+5 exec $path/changetheme.sh 5 
	Mod4+Ctrl+6 exec $path/changetheme.sh 6 
	Mod4+Ctrl+7 exec $path/changetheme.sh 7 
	Mod4+Ctrl+8 exec $path/changetheme.sh 8 
	Mod4+Ctrl+9 exec $path/changetheme.sh 9
	Mod4+Ctrl+left exec $path/changetheme.sh prev
	Mod4+Ctrl+right exec $path/changetheme.sh next
	Mod4+Ctrl+Space exec $path/changetheme.sh
	Mod4+Ctrl+s exec $path/changetheme.sh save
}
" >> ~/.config/sway/config
cd $path
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
	local oldones=($(ls -d $save_path/old*/ 2> /dev/null))
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
	cd $path
}

function moveBackupConfig {
	local backupfolders=($(cat $path/system/configFolders.txt))
	mkdir -p $1
	for i in "${backupfolders[@]}"; do
		mkdir -p $1/$i 2> /dev/null
		case $2 in
			move) mv  ~/.config/$i/* $1/$i/ 2> /dev/null 2> /dev/null;;
			copy| *) cp -r ~/.config/$i/* $1/$i/ 2> /dev/null 2> /dev/null;;
		esac
	done
}

function prepareFolders {
	local backupones=($(ls -d $save_path/$1*/ 2> /dev/null))
	local backupones=(${backupones[*]/%\/})

	for (( j=${#backupones[@]}; j>7; j-- )); do
		rm -r ${backupones[ (( j - 1 ))]} 2> /dev/null
	done

	for (( i=${#backupones[@]}; i>0; i-- )); do
		mv ${backupones[(( i - 1 ))]} $save_path/$1$(( i + 1 )) 2> /dev/null
	done
}

### lol
function wordCheck () {

	#working with $folder
	checksave #function
	checkNextPrev #function
	checkNum #function
	
	if [ "$folder" == "fuck" ]
	then
		echo "Hey, it's you messed that up, don't blame me for that. Or send an issue to github.com/indicozy"
		notify-send "Hey, it's you messed that up, don't blame me for that." "Or send an issue to github.com/indicozy"

	elif [ "$folder" == "save" ]
	then
		backupConfig #function
		echo "Files saved to $save_path/backup"
		notify-send "Config saved!" "Folder is located at: $save_path/backup"
	elif [ "$folder" == "fuckgoback" -o "$folder" == "goback" ]
	then
		if goback; then
			swaymsg reload
			echo "Back to the previous theme from history."
			notify-send "Back to the previous theme." "Be careful next time"
		else
			echo "[Error] No older folder found"
			notify-send "Error at Theme Changer" "No older folder found"
		fi
	elif [ -d "$path/configs/$folder" ]
		then
			prepareFolders old
			moveBackupConfig $save_path/old move
			copyToConfig #function
			autoAppend #function
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

	zenity_array+="\\ "
	zenity_array+="prev 'Go to the previous theme' \\ "
	zenity_array+="next 'Go to the next theme' \\ "
	zenity_array+="save 'Save your config' \\ "
	zenity_array+="goback 'Back to previous config' \\ "

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
	if [[ $? -eq 0 ]]; then
		wordCheck
	fi
}


##### MAIN
if [[ "$path" != *sway-dotfiles-script ]]; then
	echo "Error: Wrong path specified! Please check that the script wasa launched from the proper folder."
	notify-send "Error: Wrong path specified!" "Please check that the script wasa launched from the proper folder."
	exit
fi

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
