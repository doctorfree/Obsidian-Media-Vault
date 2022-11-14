#!/bin/bash

roon -z "HomePod Max"
[ -d data ] || mkdir data

artistarg=
[ "$1" ] && artistarg="-a $1"

echo "Please be patient while the Roon Audio System is queried. This may take some time."
roon -l arttracks ${artistarg} > "data/tracks_by_artist_$1.txt"
