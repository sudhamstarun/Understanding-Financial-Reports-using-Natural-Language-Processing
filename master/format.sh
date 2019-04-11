

#for dir in m/*/
#do
#	for file in $dir/*
#	do
#		if [ -d m_format/$(basename $dir) ]
#		then
#			(python3 format.py $file 1.csv && cd m_format/$(basename $dir) && cd ../../ && mv 1.csv m_format/$(basename $dir)  && mv m_format/$(basename $dir)/1.csv $(basename $file))
#(python3 format.py $file 1.csv && mv 1.csv m_format/$(basename $dir)  && mv m_format/$(basename $dir)/1.csv $(basename $file))
#		else
#			(python3 format.py $file 1.csv  && cd m_format && mkdir "$(basename $dir)" && cd ../ && mv 1.csv m_format/$(basename $dir)  && cd m_format/$(basename $dir) && mv 1.csv $(basename $file))
#		fi

#done
#done

#!/bin/bash

for dir in m/*/
do
	for file in $dir/*
	do
		if [ -d m_format/$(basename $dir) ]
		then
			(python3 format.py $file 1.csv  && mv 1.csv m_format/$(basename $dir)  && cd m_format/$(basename $dir) && mv 1.csv $(basename $file))
		else
			(python3 format.py $file 1.csv  && cd m_format && mkdir "$(basename $dir)" && cd ../ && mv 1.csv m_format/$(basename $dir)  && cd m_format/$(basename $dir) && mv 1.csv $(basename $file))
		fi

done
done
