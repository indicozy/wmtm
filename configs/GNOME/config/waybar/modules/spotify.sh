#!/bin/bash

class=$(playerctl metadata --player=spotify --format '{{lc(status)}}')
icon=""
limit=100

if [[ $class == "playing" ]]; then
	info=$(playerctl metadata --player=spotify --format '{{artist}} {{album}} - {{title}}' | sed 's/"//g')
	if [[ ${#info} -gt $limit ]]; then
		info=$(echo $info | cut -c1-$limit)"..."
	fi
	text=$icon" "$info
elif [[ $class == "paused" ]]; then
      text=$icon
elif [[ $class == "stopped" ]]; then
	text=""
fi

echo -e "{\"text\":\""$text"\", \"class\":\""$class"\"}"
