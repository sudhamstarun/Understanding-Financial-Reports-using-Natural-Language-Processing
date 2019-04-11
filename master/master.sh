#!/bin/bash

cd /home2/vvsaripalli/master && python3 parserExtractor.py /home2/vvsaripalli/master/0000002646_N-CSR_0001104659-06-058353.txt
mv /home2/vvsaripalli/master/0000002646_N-CSR_0001104659-06-058353 /home2/vvsaripalli/master/master
./checkTableN-CSR.sh 
./format.sh 
./blank.sh 
./emptydir.sh 
./formatword.sh 
./libor.sh 