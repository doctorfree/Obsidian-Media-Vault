#!/bin/bash

cd data

java -jar /usr/share/java/saxon.jar \
     -o html/Library-$$.html albumList.xml albumList.xsl

cd ..

pandoc -f html -t markdown_mmd -o markdown/Library-$$.md data/html/Library-$$.html
