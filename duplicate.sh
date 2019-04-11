#!/bin/bash

for file in files/*
do
(python3 parserExtractor.py $file)
done
for dir in files/*/
do
(mv $dir master/)
done
(./checkTable.sh )
rm -r master/*	 
(./format.sh )
rm -r m/*
(./blank.sh )
(./emptydir.sh )
(./formatword.sh )
rm -r m_format/*
(./libor.sh)
rm -r files/*
 