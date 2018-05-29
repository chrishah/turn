#!/bin/bash

if [ $1 ]
then
	base=$1
else
	base="./"
fi

for dir in $(find $base -type d | grep "\/\." -v)
do 
	echo -e "Looking at: $dir"
	ls -hlrtgG $dir | grep -v " CONTENT.txt$" > $dir/CONTENT.txt
	if [ -s "$dir/.gitignore" ]
	then
		ignore=$(cat $dir/.gitignore)
	else
		ignore=""
	fi

	for file in $(ls -lagG $dir | grep "^d" -v | grep "^total" -v | awk '{print $3,$7}' | sed 's/ /|/')
	do 
		size=$(echo $file | cut -d "|" -f 1)
		if [ "$size" -gt 50000 ]
		then 
			ignore="$ignore\n$(echo -e "$file" | cut -d "|" -f 2)"
		fi
	done
	newignore=$(echo -e "$ignore" | grep "^$" -v | sort -n | uniq -c | grep "   1 " | awk '{print $2}')
	if [ "$newignore" ]
	then
		echo -e "Adding to $dir/.gitignore:\n$newignore"
	fi
	ignore=$(echo -e "$ignore" | sort -n | uniq | grep "^$" -v)
	echo -e "$ignore" > $dir/.gitignore
done

