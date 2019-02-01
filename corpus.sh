
#!/bin/bash

for dir in /home2/vvsaripalli/CDS2/*/
	do
		(cd "$dir")
		if [ -d $dir/N-CSR ]
		then
			(
			for file in $dir/N-CSR/*
			
			do
				if [ -f $file ]
			then
				
				 (mv /home2/vvsaripalli/CDS2/$(basename $dir)/N-CSR/$(basename $file) /home2/vvsaripalli/CDS2/$(basename $dir)/N-CSR/$(basename $dir)_N-CSR_$(basename $file) &&  cp /home2/vvsaripalli/CDS2/$(basename $dir)/N-CSR/$(basename $dir)_N-CSR_$(basename $file) /home2/vvsaripalli/Corpus )
fi
			done
			)
fi
done


