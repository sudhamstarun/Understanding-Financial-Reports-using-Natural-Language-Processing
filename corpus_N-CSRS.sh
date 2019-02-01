#!/bin/bash

for dir in /home2/vvsaripalli/backup2/CDS_N-CSRS/*/
	do
		(cd "$dir")
		if [ -d $dir/N-CSRS ]
		then
			(
			for file in $dir/N-CSRS/*
			
			do
				if [ -f $file ]
			then
				
				 (mv /home2/vvsaripalli/backup2/CDS_N-CSRS/$(basename $dir)/N-CSRS/$(basename $file) /home2/vvsaripalli/backup2/CDS_N-CSRS/$(basename $dir)/N-CSRS/$(basename $dir)_N-CSRS_$(basename $file) &&  cp /home2/vvsaripalli/backup2/CDS_N-CSRS/$(basename $dir)/N-CSRS/$(basename $dir)_N-CSRS_$(basename $file) /home2/vvsaripalli/Corpus_N-CSRS )
fi
			done
			)
fi
done


