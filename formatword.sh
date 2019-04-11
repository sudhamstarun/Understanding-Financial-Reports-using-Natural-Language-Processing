

#for dir in m_format/*/
#do
#	for file in $dir/*
#	do

#		if [ -d m_formatwithouttotal/$(basename $dir) ]
#		then
#			(python3 formatword.py $file 1.csv && cd m_formatwithouttotal/$(basename $dir) && cd ../../ && mv 1.csv m_formatwithouttotal/$(basename $dir)  && mv m_formatwithouttotal/$(basename $dir)/1.csv $(basename $file))
#		else
#			(python3 formatword.py $file 1.csv  && cd m_formatwithouttotal && mkdir "$(basename $dir)" && cd ../ && mv 1.csv m_formatwithouttotal/$(basename $dir)  && cd m_formatwithouttotal/$(basename $dir) && mv 1.csv $(basename $file))
#		fi

#done
#done

#!/bin/bash

for dir in m_format/*/
do
	for file in $dir/*
	do

		if [ -d m_formatwithouttotal/$(basename $dir) ]
		then
			(python3 formatword.py $file 1.csv && mv 1.csv m_formatwithouttotal/$(basename $dir) && cd m_formatwithouttotal/$(basename $dir) && mv 1.csv $(basename $file))
		else
			(python3 formatword.py $file 1.csv  && cd m_formatwithouttotal && mkdir "$(basename $dir)" && cd .. && mv 1.csv m_formatwithouttotal/$(basename $dir)  && cd m_formatwithouttotal/$(basename $dir) && mv 1.csv $(basename $file))
		fi

done
done

