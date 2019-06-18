#!/bin/bash

for dir in /home2/vvsaripalli/backup2/SECReports/unstructured_N-CSRS/*/
do
	(cd "$dir")
	# for d in $dir/*/
	# do
	# 	(cd "$d")
		if [ -d /home2/vvsaripalli/backup2/SECReports/unstructured_N-CSRS/$(basename $dir)/N-CSRS ]
		then
			(
			for file in $dir/N-CSRS/*
			do
				if grep -iq "credit default swap" $file 
					then

					if [ -f /home2/vvsaripalli/backup2/CDS_N-CSRS/$(basename $dir)/N-CSRS/$(basename $file) ]
					then
						(cd )
					elif [ -d /home2/vvsaripalli/backup2/CDS_N-CSRS/$(basename $dir) ]
						then
						( mv $file /home2/vvsaripalli/backup2/CDS_N-CSRS/$(basename $dir)/N-CSRS ) 
					else
						(mkdir /home2/vvsaripalli/backup2/CDS_N-CSRS/$(basename $dir) && mkdir /home2/vvsaripalli/backup2/CDS_N-CSRS/$(basename $dir)/N-CSRS && mv $file /home2/vvsaripalli/backup2/CDS_N-CSRS/$(basename $dir)/N-CSRS ) 
					fi

			else
				if [ -f /home2/vvsaripalli/backup2/NoCDS_N-CSRS/$(basename $dir)/N-CSRS/$(basename $file) ]
				then
					(cd )
				elif [ -d /home2/vvsaripalli/backup2/NoCDS_N-CSRS/$(basename $dir) ]
					then
				( mv $file /home2/vvsaripalli/backup2/NoCDS_N-CSRS/$(basename $dir)/N-CSRS ) 
				else
				(mkdir /home2/vvsaripalli/backup2/NoCDS_N-CSRS/$(basename $dir) && mkdir /home2/vvsaripalli/backup2/NoCDS_N-CSRS/$(basename $dir)/N-CSRS && mv $file /home2/vvsaripalli/backup2/NoCDS_N-CSRS/$(basename $dir)/N-CSRS ) 
			fi
		fi

		done
		)
		fi
	done

