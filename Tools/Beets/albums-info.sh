#!/bin/bash

MDIR="/u/audio/Music"
TOP="${HOME}/Documents/Obsidian"

[ -d ${TOP} ] || {
    echo "${TOP} does not exist or is not a directory. Exiting."
    exit 1
}

cd ${TOP}

[ -d Beets ] || mkdir Beets

for artistdir in ${MDIR}/*
do
  [ -d "${artistdir}" ] || continue
  artist=`basename "${artistdir}"`
  [ -d "Beets/${artist}" ] || mkdir "Beets/${artist}"
  echo "# Albums by ${artist}" > "Beets/${artist}/albums.md"
  echo "" >> "Beets/${artist}/albums.md"
  echo "## Albums" >> "Beets/${artist}/albums.md"
  echo "" >> "Beets/${artist}/albums.md"
  beet info --album \
            --library \
            --include-keys=album,albumartist,artpath,genre,year,mb_albumartistid,mb_albumid,mb_releasegroupid \
            albumartist:"${artist}" path:"${artistdir}" >> "Beets/${artist}/albums.md"
  echo "END" >> "Beets/${artist}/albums.md"
done
