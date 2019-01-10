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
			# (perl ~/Downloads/SECReports/SEC-Edgar-CDS-Record-Extractor/extract.pl $file > ~/Downloads/SECReports/$(basename $file ) && cd ~/Downloads/SECReports/)
			 (perl ~/Downloads/SECReports/SEC-Edgar-CDS-Record-Extractor/extract.pl $file > ~/Downloads/SECReports/1)

			# if [ grep -R BUY ~/Downloads/SECReports/1 ] && [ grep -R SELL ~/Downloads/SECReports/1 ]  && [ grep -R COUNTERPARTY ~/Downloads/SECReports/1 ]  
			if  grep -iq "buy" ~/Downloads/SECReports/1 && grep -iq "SELL" ~/Downloads/SECReports/1  && grep -iq "COUNTERPARTy" ~/Downloads/SECReports/1  

			# ( grep "BUY" ~/Downloads/SECReports/1 )
			# if [ "$?" == 0 ]
				then
				if [ -f ~/Downloads/SECReports/Structured/$(basename $dir)/N-CSR/$(basename $file) ]
				then
					(rm ~/Downloads/SECReports/1)
				else
				(cd ~/Downloads/SECReports/Structured/ && mkdir "$(basename $dir)" && cd ~/Downloads/SECReports/Structured/$(basename $dir) && mkdir "N-CSR" && mv ~/Downloads/SECReports/N-CSR/$(basename $dir)/$(basename $d)/N-CSR/$(basename $file) ~/Downloads/SECReports/Structured/$(basename $dir)/N-CSR/ && rm ~/Downloads/SECReports/1 )
				fi

			else
				if [ -f ~/Downloads/SECReports/unstructured/$(basename $dir)/N-CSR/$(basename $file) ]
				then
					(rm ~/Downloads/SECReports/1)
				else
				(cd ~/Downloads/SECReports/unstructured/ && mkdir "$(basename $dir)" && cd ~/Downloads/SECReports/unstructured/$(basename $dir) && mkdir "N-CSR" && mv ~/Downloads/SECReports/N-CSR/$(basename $dir)/$(basename $d)/N-CSR/$(basename $file) ~/Downloads/SECReports/unstructured/$(basename $dir)/N-CSR/ && rm ~/Downloads/SECReports/1 )

			fi
		    fi
			done
			)

		fi

done
done

