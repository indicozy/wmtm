#! /bin/bash
# Script for changing themes of sway-dotfiles-script
# Developed and maintained by indicozy
# ver: 1.0

path=$1			

folderNumber=($(ls -d $path/customization/sway/*.txt))
folderNumber=(${folderNumber[*]/%\/})
folderNumber=(${folderNumber[*]/*\/})

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
	# exit
else
	eval $VISUAL $path/customization/sway/$changeFile
	if zenity --question --title="Reload?" --text="Do you want to reload config?" --width=300 --height=300; then
		$path/install.sh $now
	fi
fi
