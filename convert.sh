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
			(gzip -d $file )
			done
			)

		fi

done


