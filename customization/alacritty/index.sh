#! /bin/bash
# Script for changing themes of wmtm
# Developed and maintained by indicozy
# ver: 1.0

path=$1			
theme_folder=$2
#copy files from $folder/config to .config
cp -r $path/configs/$theme_folder/config/alacritty ~/.config

# append text to make alacritty config to work with this script
# this regex is a total piece of shit. change it
sed -i "s/size: [0-9]\\{1\}\\.[0-9]/$(< $path/customization/alacritty/size.txt)/" ~/.config/alacritty/alacritty.yml
sed -i "s/size: [0-9]\\{2\}\\.[0-9]/$(< $path/customization/alacritty/size.txt)/" ~/.config/alacritty/alacritty.yml
sed -i "s/size: [0-9]\\{3\}\\.[0-9]/$(< $path/customization/alacritty/size.txt)/" ~/.config/alacritty/alacritty.yml
