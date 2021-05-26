#! /bin/bash
# Installer script for sway-dotfiles-script
# Developed and maintained by indicozy
# ver: 1.0

function prepareSavedConfigs {
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

function autoAppend {
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
}

function backupConfig {
	local backupfolders=(alacritty mako rofi sway swaylock waybar wlogout zathura) 
	for i in "${backupfolders[@]}"
	do
		mkdir -p $save_path/YourDefault/$i > /dev/null
		cp -r ~/.config/$i/* $save_path/YourDefault/$i/
	done
}
function backupSwitcher {
	rm -r $save_path/SwitcherBackup
	mv $path $save_path/SwitcherBackup
}

function installSwitcher {
	mkdir $path 2> /dev/null
	cd $git_path
	cp -r configs system customization changetheme.sh install.sh LICENSE README.md $path
}

function installApplications {
	clear
	install_answer=1

if [ $dialog_found -eq 1 ]; then
	if dialog --title "Install Packages" \
		--yesno "Would you like to install necessary packages first?" 7 50
		then
			dialog --title "Note"\
				--msgbox "This script will install only required packages, check out for additional packages on README.md" 10 50
			install_answer=0
	fi

else
	read -p "Would you like to install necessary packages first? y/n: " install_answer
	if [ $install_answer = 'y' -o $install_answer = 'Y' ]; then
		echo "This script will install only required packages, check out for additional packages on README.md."
		read -p " Type anything to continue..." -n 1 install_answer
		install_answer=0
	else 
		install_answer=1
	fi
fi
if [ $install_answer -eq 0 ]; then
			clear
			sudo pacman -S --needed alacritty mako sway wlogout zenity waybar dialog
			yay -S --needed swaylock-effects rofi-lbonn-wayland-git wlogout autotiling nerd-fonts-fira-code
			echo "Packages are installed, now insalling the script..."
		else
			clear
			echo "You chose not to install packages."
	fi
sleep 1
}

function distroIsArch {
	if ! cat /etc/*-release | grep Arch\ Linux > /dev/null
	then
		return 1
	fi
	return 0
}

function checkPackageManager {
	if distroIsArch; then
		installApplications
	else
		echo "Sorry, but your distro is not Arch linux (or script could not find your distro)\nPlease contact me at github.com/indicozy to add your distro"
		sleep 5
	fi
}

function killAllProcesses () {
	#kill all panel processes
	killall $(cat $path/system/killprocesses.txt) 2> /dev/null
	cd $path
}


####### MAIN
path=~/.sway-dotfiles-script
git_path=($(pwd))
save_path=~/Documents/sway_configs_saved
answer=1
dialog_found=0

if ! [[ "$git_path" == *"sway-dotfiles-script" ]]; then
	echo "ERROR: Most likely you are installing from the wrong folder, please check my github: https://github.com/indicozy/sway-advanced-config"
	exit
fi


if [ -f /usr/bin/dialog ] || [ -f /bin/dialog ]; then
	dialog --title "Install Theme Changer" \
		--yesno "Would you like to install the Theme Changer? y/n: " 10 50
	answer=$?
	dialog_found=1
else
	echo "Welcome to Sway Theme Changer!"
	read -p "Would you like to install the Theme Changer? y/n: " answer
	if [ "$answer" == "y" -o "$answer" == "Y" ]; then
		answer=0
	fi
fi

#0 is True, i.e. no errors
if [ $answer -eq 0 ]; then
	checkPackageManager
	prepareSavedConfigs
	backupConfig
	backupSwitcher
	installSwitcher
	autoAppend
	killAllProcesses
	swaymsg reload
	notify-send "You are ready to go!" "Just click Ctrl+Super+Space"

	clear
	if [ $dialog_found -eq 1 ]; then
		dialog --title "Installation Complete"\
			--msgbox "Your previous theme before installation was saved in $save_path/YourDefault\n\n\n     Just click Ctrl+Super+Space to start!" 10 50

	else
		echo -e "Installation Complete!\n\nYour previous theme before installation was saved in $save_path/YourDefault\n\nJust click Ctrl+Super+Space to start!\n"
	fi

else
	clear
	echo "You chose not to install. No files has been changed."
fi
