#!/bin/bash

for dir in ~/Downloads/SECReports/N-CSR/*/
do
	for d in $dir/*/
	do
		(cd "$d")
		if [ -d ~/Downloads/SECReports/N-CSR/$(basename $dir)/$(basename $d)/N-CSR ]
		then
			(
			for file in $d/N-CSR/*
			do
			(perl ~/Downloads/SECReports/SEC-Edgar-CDS-Record-Extractor/extract.pl $file > ~/Downloads/SECReports/$(basename $file ))
			# (cd $d/N-CSR/ && ls > ~/Desktop/FYPScripts/$(basename $file))
			# (gzip -d $file)
			done
			)

		fi

done
done

