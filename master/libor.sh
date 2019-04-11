#!/bin/bash
#!/bin/bash

for dir in m_formatwithouttotal/*/
do
	for file in $dir/*
	do
	#(python3 /home2/vvsaripalli/usefulTables/blank.py $file >>1.txt)
			if grep -iq "libor" $file
			then
				(rm $file)
				#echo $file
			
		fi
if grep -iq "EUR" $file
			then
				(rm $file)
				#echo $file
			
		fi

if grep -iq "corporate bonds" $file
			then
				(rm $file)
				#echo $file
			
		fi

if grep -iq "convertible bonds" $file
			then
				(rm $file)
				#echo $file
			
		fi

if grep -iq "asset-backed" $file
			then
				(rm $file)
				#echo $file
			
		fi

if grep -iq "written options" $file
			then
				(rm $file)
				#echo $file
			
		fi

if grep -iq "forward" $file
			then
				(rm $file)
				#echo $file
			
		fi

if grep -iq "forwards" $file
			then
				(rm $file)
				#echo $file
			
		fi

if grep -iq "commercial mortgage" $file
			then
				(rm $file)
				#echo $file
			
		fi

if grep -iq "contracts" $file
			then
				(rm $file)
				#echo $file
			
		fi

if grep -iq "cash" $file
			then
				(rm $file)
				#echo $file
			
		fi


if grep -iq "investments" $file
			then
				(rm $file)
				#echo $file
			
		fi

if grep -iq "consumer" $file
			then
				(rm $file)
				#echo $file
			
		fi

if grep -iq "floating" $file
			then
				(rm $file)
				#echo $file
			
		fi

if grep -iq "municipal" $file
			then
				(rm $file)
				#echo $file
			
		fi

if grep -iq "bonds" $file
			then
				(rm $file)
				#echo $file
			
		fi




done
done



