#!/bin/bash
#
# Entries look like:
#
# Track titles by “Brother” Jack McDuff on album The Prestige Years :
# 
# 1. The Honeydripper
# 2. Brother Jack
# 3. Sanctified Waltz
# 4. Yeah, Baby
# 5. Mellow Gravy
# 6. He's a Real Gone Guy
# 7. Rock Candy

if [ "$1" ]
then
  TXT="data/$1.txt"
  MDN="$1.md"
else
  TXT="data/tracks_by_artist.txt"
  MDN="Tracks_by_Artist.md"
fi

echo "# Roon Tracks by Artist" > ${MDN}
echo "" >> ${MDN}
cat data/nav.md >> ${MDN}

cat ${TXT} | sed -e "s/Track titles by /### /" | sed -e "s/ :$//" >> ${MDN}
