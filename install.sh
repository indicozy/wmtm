
if zenity --question --width=400 --title="Theme Changer" --text="Would you like to install the Theme Changer?\nPlease check if you installed all dependencies first"
then
	git_path=($(pwd))
	path=~/.sway-dotfiles-script

	mkdir -p ~/Documents/sway_configs_saved
	cd ~/Documents/sway_configs_saved
	saved_folders=($(ls -d YourDefault*))
		for (( i=${#saved_folders[@]}; i>0; i--))
		do
			mv ~/Documents/sway_configs_saved/"${saved_folders[$(( i - 1 ))]}" ~/Documents/sway_configs_saved/YourDefault$(( i + 1))
		done
		for (( i=${#saved_folders[@]}; i>7; i--)) #removes old folers up to 7+1 (1 is newly created) folders
		do
			rm -r ~/Documents/sway_configs_saved/${saved_folders[(($i - 1))]}
		done

	backupfolders=(alacritty mako nwg-dock nwg-launchers nwg-panel rofi sway swaylock waybar wlogout zathura) 
	for i in "${backupfolders[@]}"
	do
		mkdir -p ~/Documents/sway_configs_saved/YourDefault1/$i
		cp -r ~/.config/$i/* ~/Documents/sway_configs_saved/YourDefault1/$i/
	done

	mkdir $path
	cd $git_path
	cp -r configs changetheme.sh install.sh LICENSE README.md $path

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

	swaymsg reload

	notify-send "You are ready to go!" "Just click Ctrl+Super+Space"

	zenity --info --title="Installation Complete" --width=400 --text="Installation complete! \nYour previous theme before installation was saved in ~/Documents/sway_configs_saved/YourDefault \nJust click Ctrl+Super+Space to start"

else
	notify-send "You chose not to install" "No files has been changed"
fi



