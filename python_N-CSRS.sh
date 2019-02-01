#!/bin/bash


for file in /home2/vvsaripalli/Corpus_N-CSRS/*
do 
	(python /home2/vvsaripalli/Bash_Scripts_and_Python_Scripts/HTML_Parser.py $file && mv $file /home2/vvsaripalli/Corpus_New )
done


