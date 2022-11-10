#!/bin/bash

java -jar /usr/share/java/saxon.jar \
     -o data/html/Library-$$.html data/xml/Library.xml data/xsl/itunes-to-html.xsl
