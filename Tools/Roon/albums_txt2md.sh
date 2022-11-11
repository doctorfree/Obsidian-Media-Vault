#!/bin/bash
#
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
