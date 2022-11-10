#!/bin/bash

# pandoc --lua-filter=data/parse-table.lua \
#        -f html -t markdown_mmd -o Library.md data/Library.html

for library in data/html/Library*.html
do
  libmd=`echo ${library} | sed -e "s/\.html/.md/"`
  pandoc -f html -t markdown_mmd -o markdown/${libmd} ${library}
done
