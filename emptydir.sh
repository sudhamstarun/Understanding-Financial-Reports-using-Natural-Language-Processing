#!/bin/bash
for dir in m_format/*/
do

if [ -n "$(find $dir -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
	(rm -rf  $dir)
fi
done

