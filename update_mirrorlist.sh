#!/bin/bash

newmirrorfile=/etc/pacman.d/mirrorlist.pacnew
mirrorfile=/etc/pacman.d/mirrorlist

if [ ! -e $newmirrorfile ]
then
    echo "$newmirrorfile : new mirrorlist file does not exist!"
    exit 1
fi

tmp_mirrorlist_file=$(mktemp)
tmp_rank_file=$(mktemp)

sed -e 's/^#//g' $newmirrorfile > $tmp_mirrorlist_file

rankmirrors -n 5 $tmp_mirrorlist_file > $tmp_rank_file

if [ $? -eq 0 ]
then
    sudo mv $mirrorfile ${mirrorfile}.old
    sudo cp $tmp_rank_file $mirrorfile
    sudo chmod 644 $mirrorfile
    sudo rm $newmirrorfile
else
    echo "failed to rank mirrors"
    exit 1
fi

rm -f $tmp_mirrorlist_file $tmp_rank_file

exit 0
