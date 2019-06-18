#!/bin/bash

for dir in /home2/vvsaripalli/backup2/SECReports/unstructured_N-CSRS/*/
do
        (cd "$dir")
        # for d in $dir/*/
        # do
        #       (cd "$d")
                if [ -d /home2/vvsaripalli/backup2/SECReports/unstructured_N-CSRS/$(basename $dir)/N-CSRS ]
                then
                        (
                        for file in $dir/N-CSRS/*
                        do
                        (gzip -d $file )
                        done
                        )

                fi

done
