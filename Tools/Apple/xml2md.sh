#!/bin/bash

# stylesheet="itunes-to-html.xsl"
# stylesheet="itunes-albums.xsl"
stylesheet="itunes-albums-by-genre.xsl"

java -jar /usr/share/java/saxon.jar \
     -o data/html/Library-$$.html /home/ronnie/transfers/Library.xml data/xsl/${stylesheet}

pandoc -f html -t markdown_mmd -o markdown/Library-$$.md data/html/Library-$$.html
