#!/bin/bash


#below is working code
for dir in ~/Downloads/SECReports/SEC-Edgar-Data/*/
do
	for d in $dir/*/
	do
		if [ -d ~/Downloads/SECReports/N-CSR/$(basename $d) ]
		then
			(cd "$d" && cd ../../../N-CSR/ && cd ~/Downloads/SECReports/N-CSR/$(basename $d) && mkdir "$(basename $dir)" && cd "$d" && mv N-CSR  ~/Downloads/SECReports/N-CSR/$(basename $d)/$(basename $dir))

	else 
		(cd "$d" && cd ../../../N-CSR/ && mkdir "$(basename $d)" && cd ~/Downloads/SECReports/N-CSR/$(basename $d) && mkdir "$(basename $dir)" && cd "$d" && mv N-CSR  ~/Downloads/SECReports/N-CSR/$(basename $d)/$(basename $dir))
		
	fi

	if [ -d ~/Downloads/SECReports/N-CSRS/$(basename $d) ]
		then
			(cd "$d" && cd ../../../N-CSRS/ && cd ~/Downloads/SECReports/N-CSRS/$(basename $d) && mkdir "$(basename $dir)" && cd "$d" && mv N-CSRS  ~/Downloads/SECReports/N-CSRS/$(basename $d)/$(basename $dir))

	else 
		(cd "$d" && cd ../../../N-CSRS/ && mkdir "$(basename $d)" && cd ~/Downloads/SECReports/N-CSRS/$(basename $d) && mkdir "$(basename $dir)" && cd "$d" && mv N-CSRS  ~/Downloads/SECReports/N-CSRS/$(basename $d)/$(basename $dir))
		
	fi


	if [ -d ~/Downloads/SECReports/N-Q/$(basename $d) ]
		then
			(cd "$d" && cd ../../../N-Q/ && cd ~/Downloads/SECReports/N-Q/$(basename $d) && mkdir "$(basename $dir)" && cd "$d" && mv N-Q  ~/Downloads/SECReports/N-Q/$(basename $d)/$(basename $dir))

	else 
		(cd "$d" && cd ../../../N-Q/ && mkdir "$(basename $d)" && cd ~/Downloads/SECReports/N-Q/$(basename $d) && mkdir "$(basename $dir)" && cd "$d" && mv N-Q  ~/Downloads/SECReports/N-Q/$(basename $d)/$(basename $dir))
		
	fi

done
done

#above is working code
