#!/bin/bash

for dir in /home2/vvsaripalli/backup2/SECReports/unstructured_N-Q/*/
do
	(cd "$dir")
	# for d in $dir/*/
	# do
	# 	(cd "$d")
		if [ -d /home2/vvsaripalli/backup2/SECReports/unstructured_N-Q/$(basename $dir)/N-Q ]
		then
			(
			for file in $dir/N-Q/*
			do
				if grep -iq "credit default swap" $file 
					then

					if [ -f /home2/vvsaripalli/backup2/CDS_N-Q/$(basename $dir)/N-Q/$(basename $file) ]
					then
						(cd )
					elif [ -d /home2/vvsaripalli/backup2/CDS_N-Q/$(basename $dir) ]
						then
						( mv $file /home2/vvsaripalli/backup2/CDS_N-Q/$(basename $dir)/N-Q ) 
					else
						(mkdir /home2/vvsaripalli/backup2/CDS_N-Q/$(basename $dir) && mkdir /home2/vvsaripalli/backup2/CDS_N-Q/$(basename $dir)/N-Q && mv $file /home2/vvsaripalli/backup2/CDS_N-Q/$(basename $dir)/N-Q ) 
					fi

			else
				if [ -f /home2/vvsaripalli/backup2/NoCDS_N-Q/$(basename $dir)/N-Q/$(basename $file) ]
				then
					(cd )
				elif [ -d /home2/vvsaripalli/backup2/NoCDS_N-Q/$(basename $dir) ]
					then
				( mv $file /home2/vvsaripalli/backup2/NoCDS_N-Q/$(basename $dir)/N-Q ) 
				else
				(mkdir /home2/vvsaripalli/backup2/NoCDS_N-Q/$(basename $dir) && mkdir /home2/vvsaripalli/backup2/NoCDS_N-Q/$(basename $dir)/N-Q && mv $file /home2/vvsaripalli/backup2/NoCDS_N-Q/$(basename $dir)/N-Q ) 
			fi
		fi

		done
		)
		fi
	done

