#! /bin/bash
# Installer script for wmtm
# Developed and maintained by indicozy
# ver: 0.11


function prepareResources {
	local folderNumber=($(ls -d $path/configs/*/))
        local folderNumber=(${folderNumber[*]/%\/})
	local folderNumber=(${folderNumber[*]/*\/})
	for i in ${folderNumber[@]}; do
		folder="$i"
		unzipResources fonts /home/$USER/.local/share/fonts
		unzipResources icons /home/$USER/.icons
		unzipResources themes /home/$USER/.themes
	done
}

function unzipResources { # $1 is the local folder from, $2 is the global folder to
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
                                        unzip -d $2/${fileNumberNoEnd[$i]} "$path/configs/$folder/resources/$1/${fileNumber[$i]}" > /dev/null
                                fi
                        fi
                done
        fi
}

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
		cp -r /home/$USER/.config/$i/* $save_path/YourDefault/$i/ 2>/dev/null
	done
}

function installSwitcher {
        if [ -d /home/$USER/.wmtm ]; then
          mkdir -p /home/$USER/Documents/wmtm_configs_saved
          mv /home/$USER/.wmtm /home/$USER/Documents/wmtm_configs_saved/wmtm_saved
        fi

	mkdir -p $path
	cp -r $git_path/configs $git_path/system $git_path/customization $git_path/changetheme.sh $git_path/install.sh $git_path/LICENSE $git_path/README.md $path
}

function killAllProcesses () {
	#kill all panel processes
	killall $(cat $path/system/killprocesses.txt) 2> /dev/null
	cd $path
}

function startInstallation {
	prepareBackedConfigs
	backupConfig
	installSwitcher
	clear
	prepareResources
}

####### MAIN
path=/home/$USER/.wmtm
git_path=($(pwd))
save_path=/home/$USER/Documents/wmtm_configs_saved

# Safety measure
if ! [[ "$git_path" == *"wmtm" ]]; then
	echo "ERROR: Most likely you are installing from the wrong folder, please check my github: https://github.com/indicozy/wmtm"
	exit 1
fi

if [ -x "$(command -v dialog)" ]; then # dialog found
	dialog --title "Install WMTM" \
		--yesno "Would you like to install the Theme Changer? y/n: " 10 50

	if [ $? -eq 0 ]; then # 1 is False
		answer="y"
	fi
else
	echo 'Warning: dialog is not installed, starting session in TUI' >&2
	echo "Welcome to WMTM"
	read -p "Would you like to install the Theme Changer? y/n: " answer
fi

if [ "$answer" == "y" -o "$answer" == "Y" ]; then
	startInstallation
	notify-send "Theme Changer successfully installed!" "Just click Ctrl+Super+Space"
	$path/changetheme.sh
else
	clear
	notify-send "You chose not to install" "No files have been changed."
fi

exit 0
