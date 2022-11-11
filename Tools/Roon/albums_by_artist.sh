#!/bin/bash

roon -z "HomePod Max"
[ -d data ] || mkdir data
echo "Please be patient while the Roon Audio System is queried. This may take some time."
roon -l artalbums > data/albums_by_artist.txt

# Entries look like:
#
# Albums by artist “Brother” Jack McDuff :
# 
# The Prestige Years
# Tobacco Road
# 
# Albums by artist “Sir” Roland Hanna :
# 
# In My Solitude: Solo Piano and Small Group Performances

TXT="data/albums_by_artist.txt"
MDN="Albums_by_Artist.md"

echo "# Roon Albums by Artist" > ${MDN}
echo "" >> ${MDN}
cat data/nav.md >> ${MDN}

cat ${TXT} | sed '/^$/d' | \
             sed -e "s/Albums by artist/### /" | \
             sed -e "s/ :$//" | \
             sed -e '/^### /! s/^/- /' >> ${MDN}
