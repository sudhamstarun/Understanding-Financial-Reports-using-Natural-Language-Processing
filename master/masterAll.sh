#!/bin/bash

for file in /home2/vvsaripalli/master/files/*
do
(cd /home2/vvsaripalli/master && python3 /home2/vvsaripalli/master/parserExtractor.py $file)
done
for dir in /home2/vvsaripalli/master/home2/vvsaripalli/master/files/*/
do
(mv $dir /home2/vvsaripalli/master/master)
done
(./checkTableN-CSR.sh )
(./format.sh )
(./blank.sh )
(./emptydir.sh )
(./formatword.sh )
(./libor.sh)
 