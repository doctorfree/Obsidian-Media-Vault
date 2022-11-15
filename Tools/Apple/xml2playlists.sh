#!/bin/bash

# stylesheet="itunes-to-html.xsl"
# stylesheet="itunes-albums-by-genre.xsl"
stylesheet="itunes-playlist.xsl"

java -jar /usr/share/java/saxon.jar \
     -o data/txt/Playlists-$$.txt /home/ronnie/transfers/Library.xml data/xsl/${stylesheet}

# pandoc -f html -t markdown_mmd -o markdown/Playlists-$$.md data/html/Playlists-$$.html
