#!/bin/bash

roon -z "HomePod Max"
[ -d data ] || mkdir data
echo "Please be patient while the Roon Audio System is queried. This may take some time."
roon -l arttracks > data/tracks_by_artist.txt
