#!/bin/bash
for dir in m_format/*/
do
	for file in $dir/*
	do
		(python3 blank.py $file >>1.txt)
			if grep -iq "empty" 1.txt
			then
				(rm $file && rm 1.txt)
			else
				(rm 1.txt)
		fi

done
done

