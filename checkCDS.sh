#!/bin/bash

for dir in /home2/vvsaripalli/backup2/unstructured/*/
do
	(cd "$dir")
	# for d in $dir/*/
	# do
	# 	(cd "$d")
		if [ -d /home2/vvsaripalli/backup2/unstructured/$(basename $dir)/N-CSR ]
		then
			(
			for file in $dir/N-CSR/*
			do
				if grep -iq "credit default swap" $file || grep -iq "cds" $file
					then

					if [ -f /home2/vvsaripalli/backup2/CDS/$(basename $dir)/N-CSR/$(basename $file) ]
					then
						(cd )
					elif [ -d /home2/vvsaripalli/backup2/CDS/$(basename $dir) ]
						then
						( cp $file /home2/vvsaripalli/backup2/CDS/$(basename $dir)/N-CSR ) 
					else
						(mkdir /home2/vvsaripalli/backup2/CDS/$(basename $dir) && mkdir /home2/vvsaripalli/backup2/CDS/$(basename $dir)/N-CSR && cp $file /home2/vvsaripalli/backup2/CDS/$(basename $dir)/N-CSR ) 
					fi

			else
				if [ -f /home2/vvsaripalli/backup2/NoCDS/$(basename $dir)/N-CSR/$(basename $file) ]
				then
					(cd )
				elif [ -d /home2/vvsaripalli/backup2/NoCDS/$(basename $dir) ]
					then
				( cp $file /home2/vvsaripalli/backup2/NoCDS/$(basename $dir)/N-CSR ) 
				else
				(mkdir /home2/vvsaripalli/backup2/NoCDS/$(basename $dir) && mkdir /home2/vvsaripalli/backup2/NoCDS/$(basename $dir)/N-CSR && cp $file /home2/vvsaripalli/backup2/NoCDS/$(basename $dir)/N-CSR ) 
			fi
		fi
		
		done
		)
		fi
	done

