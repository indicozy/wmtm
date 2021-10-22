#! /bin/bash
# Installer script for sway-dotfiles-script
# Developed and maintained by indicozy
# ver: 0.11

function prepareBackedConfigs {
	mkdir -p $save_path
	local saved_folders=($(ls -d $save_path/YourDefault*))
		for (( i=${#saved_folders[@]}; i>0; i--))
		do
			mv "${saved_folders[$(( i - 1 ))]}" $save_path/YourDefault$(( i + 1)) 2> /dev/null
		done

	#update new arrangement of saved folders
	local saved_folders=($(ls -d $save_path/YourDefault*))
		for (( i=${#saved_folders[@]}; i>7; i--)) #removes old folers up to 7+1 (1 is newly created) folder
		do
			rm -r ${saved_folders[$(($i - 1))]}
		done
}

function backupConfig {
	local backupfolders=$(cat $path/system/configFolders.txt)
	for i in $backupfolders
	do
		mkdir -p $save_path/YourDefault/$i > /dev/null
		cp -r /home/$USER/.config/$i/* $save_path/YourDefault/$i/
	done
}

function installSwitcher {
	mkdir -p $path 2> /dev/null
	cp -r $git_path/configs $git_path/system $git_path/customization $git_path/changetheme.sh $git_path/install.sh $git_path/LICENSE $git_path/README.md $path
}

function killAllProcesses () {
	#kill all panel processes
	killall $(cat $path/system/killprocesses.txt) 2> /dev/null
	cd $path
}


####### MAIN
path=/home/$USER/.sway-dotfiles-script
git_path=($(pwd))
save_path=/home/$USER/Documents/sway_configs_saved
answer=1
dialog_found=0

# Safety measure
if ! [[ "$git_path" == *"sway-dotfiles-script" ]]; then
	echo "ERROR: Most likely you are installing from the wrong folder, please check my github: https://github.com/indicozy/sway-advanced-config"
	exit 1
fi

# Stopped here

# if dialog program exists
if [ -x "$(command -v dialog)" ]; then
	dialog_found=1
fi

if [ $dialog_found -eq 1 ]; then
	dialog --title "Install Theme Changer" \
		--yesno "Would you like to install the Theme Changer? y/n: " 10 50
	answer=$? #0 is True, i.e. no errors
else
	echo 'Warning: dialog is not installed, starting session in TUI' >&2
	echo "Welcome to Sway Theme Changer!"
	read -p "Would you like to install the Theme Changer? y/n: " answer
	if [ "$answer" == "y" -o "$answer" == "Y" ]; then
		answer=0 #0 is True, i.e. no errors
	fi
fi

clear

#0 is True, i.e. no errors
if [ $answer -eq 1 ]; then # 1 is False
	echo "You chose not to install. No files has been changed."
	exit 0
fi

prepareBackedConfigs
backupConfig
installSwitcher
killAllProcesses
swaymsg reload # change for other WMs

clear

if [ $dialog_found -eq 1 ]; then
	dialog --title "Installation Complete"\
		--msgbox "Your previous theme before installation was saved in $save_path/YourDefault\n\n\n     Just click Ctrl+Super+Space to start!" 10 50
	clear

else
	echo -e "Installation Complete!\n\nYour previous theme before installation was saved in $save_path/YourDefault\n\nJust click Ctrl+Super+Space to start!\n"
fi

notify-send "You are ready to go!" "Just click Ctrl+Super+Space"

$path/changetheme.sh

exit 0
