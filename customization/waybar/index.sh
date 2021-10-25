path=$1			
theme_folder=$2
cp -r $path/configs/$theme_folder/config/waybar ~/.config
old=$IFS
IFS='\n'
for i in $(cat $path/customization/waybar/toRemove.txt); do
	#if the word was commented out...
	if [[ "$i" == "#"* ]] ;then
		continue
	fi
	grep -v "\"$i\"," ~/.config/waybar/config > ~/.config/waybar/config.temp && mv ~/.config/waybar/config.temp ~/.config/waybar/config
	grep -v "\"$i\" ," ~/.config/waybar/config > ~/.config/waybar/config.temp && mv ~/.config/waybar/config.temp ~/.config/waybar/config
done
	
IFS=$old
