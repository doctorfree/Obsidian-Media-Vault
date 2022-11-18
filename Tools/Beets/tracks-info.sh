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
  for albumdir in "${artistdir}"/*
  do
    [ -d "${albumdir}" ] || continue
    album=`basename "${albumdir}"`
    [ -d "Beets/${artist}/${album}" ] || mkdir "Beets/${artist}/${album}"
    echo "# Tracks on \"${album}\" by ${artist}" > "Beets/${artist}/${album}/tracks.md"
    echo "" >> "Beets/${artist}/${album}/tracks.md"
    echo "## Tracks" >> "Beets/${artist}/${album}/tracks.md"
    echo "" >> "Beets/${artist}/${album}/tracks.md"
    beet info --library --include-keys=album,albumartist,artist,catalognum,format,genre,label,length,title,track,tracktotal,year \
         albumartist:"${artist}" \
         path:"${albumdir}" >> "Beets/${artist}/${album}/tracks.md"
    echo "END" >> "Beets/${artist}/${album}/tracks.md"
  done
done
