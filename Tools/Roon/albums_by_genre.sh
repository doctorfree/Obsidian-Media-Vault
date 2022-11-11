#!/bin/bash
#
# Entries look like:
#
# Albums in genre Art Music > Classical > Classical :
# 
# STRING QUARTETS vol. I Haydn - Solberg - Grieg

roon -z "HomePod Max"
[ -d data ] || mkdir data
echo "Please be patient while the Roon Audio System is queried. This may take some time."
roon -g __all__ -l genalbums > data/albums_by_genre.txt

TXT="data/albums_by_genre.txt"
MDN="Albums_by_Genre.md"
PRE="/tmp/pre$$"
TBL="/tmp/tbl$$"

echo "# Roon Albums by Genre" > ${MDN}
echo "" >> ${MDN}

cat ${TXT} | sed '/^$/d' | \
             sed -e "s/Albums in genre/## /" | \
             sed -e "s/ :$//" | \
             sed -e '/^## /! s/^/- /' >> /tmp/pre$$

grep "^## " /tmp/pre$$ | sed -e "s/^## /| \*\*\[/" > /tmp/tbl$$
cat /tmp/tbl$$ >> ${MDN}
echo "" >> ${MDN}
cat /tmp/pre$$ >> ${MDN}

rm -f "/tmp/pre$$" "/tmp/tbl$$"
