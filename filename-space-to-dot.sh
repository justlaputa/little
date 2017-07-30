#!/bin/bash

# change all files with space in the name to dot
find . -type f -name "* *" | while read F
do
  FF=`echo $F | sed -e 's/ /\./g' -e 's/[()]//g'`
  mv -iv "$F" "$FF"
done
