# Tools

Several custom scripts and utilities were used to automate the generation of markdown files in the Obsidian Media Vault. For example, the source data used in the generation of the Books sub-vault consisted of a CSV export of a Goodreads library along with XML format RSS feeds of all the bookshelves in that Goodreads library. The CSV and XML were processed using tools like [csvkit](https://csvkit.readthedocs.io/en/latest), `grep`, `sed`, `awk`, and other system utilities.

## Books

The script used to generate the Markdown from Goodreads shelf XML RSS feeds:

```shell
#!/bin/bash

# Enter urls to your goodreads rss feed below.
# You can find it by navigating to one of your goodreads shelves and
# clicking the "RSS" button at the bottom of the page.

baseurl="https://www.goodreads.com/review/list_rss/2401015?key=S32et3Fz0RHR5EvFXCAxe6F3vqx_GasSQVSDLnEQMQ_uO2kT&shelf="

shelves="anthologies biography bob brautigan conklin essays farmer fiction \
         huxley leary literature mathematics mcmurtry murakami nonfiction \
         novels p-k-dick palahniuk philosophy poetry reference robbins science \
         science-fiction short-stories steinbeck vonnegut currently-reading \
         read to-read"

# Enter the path to your Vault or XML download folder
vaultpath="/home/ronnie/Documents/Obsidian/Books/tools/data/xml"

for shelf in ${shelves}
do
  echo "Processing ${shelf}"
  url="${baseurl}${shelf}"
  # Get the last componenet of the url
  this_shelf=`echo ${url} | awk -F '=' ' { print $NF } '`
  # This grabs the data from the rss feed and formats it
  IFS=$'\n' feed=$(curl --silent "$url" | grep -E '(book_large_image_url>|book_id>)' | \
  sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' \
    -e "s/Ron.s bookshelf: ${this_shelf}//" \
    -e 's/<book_large_image_url>//' -e 's/<\/book_large_image_url>/ | /' \
    -e 's/<book_id>//' -e 's/<\/book_id>/ | /' \
    -e 's/^[ \t]*//' -e 's/[ \t]*$//' | \
    tail +3 | \
    fmt | paste -s -d' \n'
  )

  # Save the formatted rss feed data
  echo "${feed}" > ${vaultpath}/${this_shelf}.md

  # Save the unformatted rss feed data
  curl --silent "$url" > ${vaultpath}/${this_shelf}.xml
done
```

The script used to generate all the individual book's Markdown:

```shell
#!/bin/bash
#
# Produce markdown table entries with csvcut
# csvcut -c 1,2,3 data/good*.csv | csvformat -D \|
#
# For example:
# echo "| Book Id | Title | Author | Additional Authors | ISBN | ISBN13 | \
#       My Rating | Average Rating | Publisher | Binding | Number of Pages | \
#       Year Published | Bookshelves | Exclusive Shelf | My Review |" > Books.md
# echo "|---------|-------|--------|--------------------|------|--------| \
#       ----------|----------------|-----------|---------|-----------------| \
#       ---------------|-------------|-----------------|-----------|" > Books.md
# csvcut -c 1,2,3,5,6,7,8,9,10,11,12,14,17,19,20 data/good*.csv | csvformat -D \| >> Books.md

BOOKS="../../Books"
update=
[ "$1" == "-u" ] && update=1

[ -d ${BOOKS} ] || mkdir ${BOOKS}

# goodreads_library_export.csv is my exported Goodreads library
cat data/goodreads_library_export.csv | while read line
do
  if [ "${first}" ]
  then
    title=`echo ${line} | csvcut -c 2`
    filename=`echo ${title} | \
        sed -e "s% %_%g" \
            -e "s%,%_%g" \
            -e "s%(%%g" \
            -e "s%)%%g" \
            -e "s%:%-%g" \
            -e "s%\#%%g" \
            -e "s%\.%%g" \
            -e "s%\"%%g" \
            -e "s%\&%and%g" \
            -e "s%\?%%g" \
            -e "s%\\'%%g" \
            -e "s%'%%g" \
            -e "s%/%-%g"`
    echo "Processing ${filename}"
    author=`echo ${line} | csvcut -c 3`
    authordir=`echo ${author} | \
        sed -e "s% %_%g" \
            -e "s%,%_%g" \
            -e "s%(%%g" \
            -e "s%)%%g" \
            -e "s%:%-%g" \
            -e "s%\#%%g" \
            -e "s%\.%%g" \
            -e "s%\"%%g" \
            -e "s%\&%and%g" \
            -e "s%\?%%g" \
            -e "s%\\'%%g" \
            -e "s%'%%g" \
            -e "s%/%-%g"`
    [ -f ${BOOKS}/${authordir}/${filename}.md ] && continue
    [ -d ${BOOKS}/${authordir} ] || mkdir ${BOOKS}/${authordir}
    bookid=`echo ${line} | csvcut -c 1`
    authors=`echo ${line} | csvcut -c 5 | sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    isbn=`echo ${line} | csvcut -c 6 | sed -e "s/=//g" -e "s/\"//g"`
    isbn13=`echo ${line} | csvcut -c 7 | sed -e "s/=//g" -e "s/\"//g"`
    rating=`echo ${line} | csvcut -c 8`
    avgrating=`echo ${line} | csvcut -c 9`
    publisher=`echo ${line} | csvcut -c 10 | sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    binding=`echo ${line} | csvcut -c 11 | sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    pages=`echo ${line} | csvcut -c 12`
    published=`echo ${line} | csvcut -c 14`
    shelves=`echo ${line} | csvcut -c 17 | sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    shelf=`echo ${line} | csvcut -c 19 | sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    review=`echo ${line} | csvcut -c 20 | sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    echo "---" > ${BOOKS}/${authordir}/${filename}.md
    echo "bookid: ${bookid}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "title: ${title}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "author: ${author}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "authors: ${authors}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "isbn: ${isbn}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "isbn13: ${isbn13}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "rating: ${rating}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "avgrating: ${avgrating}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "publisher: ${publisher}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "binding: ${binding}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "pages: ${pages}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "published: ${published}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "shelves: ${shelves}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "shelf: ${shelf}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "review: ${review}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "---" >> ${BOOKS}/${authordir}/${filename}.md
    echo "" >> ${BOOKS}/${authordir}/${filename}.md
    echo "# ${title}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "" >> ${BOOKS}/${authordir}/${filename}.md
    echo "By ${author}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "" >> ${BOOKS}/${authordir}/${filename}.md
    # book_covers.md was generated from the XML of all my shelves
    coverurl=`grep "|${bookid}|" data/book_covers.md | tail -1 | awk -F '|' ' { print $3 } '`
    [ "${coverurl}" ] && {
      echo "![](${coverurl})" >> ${BOOKS}/${authordir}/${filename}.md
      echo "" >> ${BOOKS}/${authordir}/${filename}.md
    }
    echo "## Book data" >> ${BOOKS}/${authordir}/${filename}.md
    echo "" >> ${BOOKS}/${authordir}/${filename}.md
    echo "[GoodReads ID/URL](https://www.goodreads.com/book/show/${bookid})" >> ${BOOKS}/${authordir}/${filename}.md
    echo "" >> ${BOOKS}/${authordir}/${filename}.md
    echo "- ISBN: ${isbn}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "- ISBN13: ${isbn13}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "- Rating: ${rating}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "- Average Rating: ${avgrating}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "- Published: ${published}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "- Publisher: ${publisher}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "- Binding: ${binding}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "- Shelves: ${shelves}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "- Shelf: ${shelf}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "- Pages: ${pages}" >> ${BOOKS}/${authordir}/${filename}.md
    echo "" >> ${BOOKS}/${authordir}/${filename}.md
    [ "${review}" ] && {
      echo "## Review" >> ${BOOKS}/${authordir}/${filename}.md
      echo "" >> ${BOOKS}/${authordir}/${filename}.md
      echo "${review}" >> ${BOOKS}/${authordir}/${filename}.md
      echo "" >> ${BOOKS}/${authordir}/${filename}.md
    }
  else
    first=1
  fi
done
```
