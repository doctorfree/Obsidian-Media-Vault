#!/bin/bash

roon -z "HomePod Max"
[ -d data ] || mkdir data
echo "Please be patient while the Roon Audio System is queried. This may take some time."
roon -l comalbums > data/albums_by_composer.txt

# Entries look like:
#

TXT="data/albums_by_composer.txt"
MDN="Albums_by_Composer.md"

echo "# Roon Albums by Composer" > ${MDN}
echo "" >> ${MDN}
cat data/nav.md >> ${MDN}

cat ${TXT} | sed '/^$/d' | \
             sed -e "s/Albums by composer/### /" | \
             sed -e "s/ :$//" | \
             sed -e '/^### /! s/^/- /' >> ${MDN}
