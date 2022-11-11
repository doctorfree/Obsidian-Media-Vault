#!/bin/bash
#
# Entries look like:
#
# Albums by composer A. Williams :
# 
# Bacon Fat
# 
# Albums by composer A. Wilson/Jordan :
# 
# Shake Some Action
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
