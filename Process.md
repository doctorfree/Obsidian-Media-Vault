---
banner: "assets/banners/Process-Banner.png"
banner_x: 0.2
banner_y: 0.8
---

# Process

Several custom scripts and utilities were used to automate the generation of markdown files in the Obsidian Media Vault. For example, the source data used in the generation of the Books sub-vault consisted of a CSV export of a Goodreads library along with XML format RSS feeds of all the bookshelves in that Goodreads library. The CSV and XML were processed using tools like [csvkit](https://csvkit.readthedocs.io/en/latest), `grep`, `sed`, `awk`, and other system utilities.

There are several other techniques for generating, curating, and maintaining media libraries in Obsidian. Some use the commercial service [Readwise](https://readwise.io) which also has an official Obsidian plugin to export from Readwise into Obsidian. These process notes describe the automated workflow to export from Goodreads to Obsidian but Readwise is an excellent service if you can afford the subscription cost and the workflow is much simpler with Readwise.

See the [See also](#see_also) section below for links to some of these other techniques.

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Beets library](#beets_library)
- [Books library](#books_library)
- [Vinyl library](#vinyl_library)
- [CD library](#cd_library)
- [Apple Music](#apple_music)
- [Roon library](#roon_library)
    - [Roon playlists](#roon_playlists)
- [Updates](#updates)
- [See also](#see_also)

## Overview

If your media libraries are cataloged in an online service such as [Discogs](https://discogs.com) or [Goodreads](https://goodreads.com) or in a media management system such as [CLZ Music](https://connect.collectorz.com) or [Invelos DVD Profiler](http://www.invelos.com/) then it is usually possible to export your online library to a file format that can be converted to markdown. Usually there is an option to export the data to CSV format and that is typically what I used although in some cases all that is available is XML format. Either will work although CSV format is much easier to parse using `csvkit`.

**[Note:]** Invelos DVD Profiler only supports data export on Windows. Each service has its own quirks and limitations. The above examples are not recommendations, they are just what I found I had to deal with in exporting my libraries. I would not recommend any of Invelos' products as they are not free and they are not supported well on Linux or Mac.

The first step is gathering data sources. That step, for me, was exporting data from various services and applications to CSV and XML format files that I could manipulate locally. Or, in the case of locally stored digital media, using various tools to query the media library (e.g.  [MusicPlayerPlus](https://github.com/doctorfree/MusicPlayerPlus#readme) for querying my Beets library and [RoonCommandLine](https://github.com/doctorfree/RoonCommandLine#readme) for querying my Roon library).

## Requirements

Most of the download, conversion, creation, and curation process was performed on Linux using the standard utilities included with every Linux distribution. It is probably also possible to use these same tools on Mac OS as its underlying operating system and utilities are BSD. I doubt this will work on Windows but maybe with WSL. Use Linux.

In addition to the standard Linux utilities, some of the conversion tools require either [Pandoc](https://pandoc.org) or [Sqlite](https://www.sqlite.org/index.html).

The CSV and XML were processed using [csvkit](https://csvkit.readthedocs.io/en/latest).

If your Linux distribution does not include `curl` then that will also need to be installed.

## Beets_library

By far, the easiest and most thorough technique for extracting data from a digital music collection is to do so with Beets. I would say the most difficult digital music system to extract data from is Apple Music. Roon is easy, online services like Spotify and Qobuz and Tidal are more difficult, but nothing has been designed that is more difficult to use than Apple Music.

To index and categorize a [Beets music library](https://beets.io/), the [MusicPlayerPlus](https://github.com/doctorfree/MusicPlayerPlus#readme) package can be used. MusicPlayerPlus provides command line utilities that can be used to query, list, and manage various aspects of a Beets library. The scripts used to produce the Beets markdown for this repository can be found in `Tools/Beets/`. Example Beets markdown can be viewed at:

- [Beets Albums by Artist](Beets_Albums_by_Artist.md)

<Details markdown="block">

The two scripts primarily used to curate the Beets markdown are [Tools/Beets/albums-info.sh](Tools/Beets/albums-info.md) and [Tools/Beets/albums_by_artist.sh](Tools/Beets/albums_by_artist.md). Both make use of the `beet info ...` command to query the Beets library for albums and tracks by artist.

### [Tools/Beets/albums-info.sh](Tools/Beets/albums-info.md) (click to collapse/expand)

```shell
#!/bin/bash

MDIR="/u/audio/Music"
TOP="${HOME}/Documents/Obsidian"

[ -d ${TOP} ] || {
    echo "${TOP} does not exist or is not a directory. Exiting."
    exit 1
}

cd ${TOP}

[ -d Beets ] || mkdir Beets

for artistdir in ${MDIR}/*
do
  [ -d "${artistdir}" ] || continue
  artist=`basename "${artistdir}"`
  [ -d "Beets/${artist}" ] || mkdir "Beets/${artist}"
  echo "# Albums by ${artist}" > "Beets/${artist}/albums.md"
  echo "" >> "Beets/${artist}/albums.md"
  echo "## Albums" >> "Beets/${artist}/albums.md"
  echo "" >> "Beets/${artist}/albums.md"
  beet info --album \
            --library \
            --include-keys=album,albumartist,artpath,genre,year,mb_albumartistid,mb_albumid,mb_releasegroupid \
            albumartist:"${artist}" path:"${artistdir}" >> "Beets/${artist}/albums.md"
  echo "END" >> "Beets/${artist}/albums.md"
done
```

### [Tools/Beets/albums_by_artist.sh](Tools/Beets/albums_by_artist.md) (click to collapse/expand)

```shell
#!/bin/bash
#
# Albums markdown in artist/albums.md looks like:
#
# # Albums by Beck
#
# ## Albums
#
# /u/audio/Music/Beck/[2017] Colors
#             album: Colors
#       albumartist: Beck
#           artpath: /u/audio/Music/Beck/[2017] Colors/cover.jpg
#             genre: Synthpop
#  mb_albumartistid: 309c62ba-7a22-4277-9f67-4a162526d18a
#        mb_albumid: df1a9202-6f1d-4b0d-a38c-049e9a90f612
# mb_releasegroupid: 84d67365-a2ca-4580-a239-9446231f27a0
#              year: 2017

BEETS="../../Beets"
INPUT="../../../Beets"
MDN="Beets_Albums_by_Artist.md"
MBURL="https://musicbrainz.org"

echo "# Beets Albums by Artist" > ${MDN}
echo "" >> ${MDN}
cat data/nav.md >> ${MDN}
[ -d ${BEETS} ] || mkdir ${BEETS}
[ -d ../../assets ] || mkdir ../../assets
[ -d ../../assets/beetscovers ] || mkdir ../../assets/beetscovers

for inputdir in ${INPUT}/*
do
  [ "${inputdir}" == "${INPUT}/*" ] && continue
  TXT="${inputdir}/albums.md"
  [ -f "${TXT}" ] || {
    echo "Missing albums.md for artist ${inputdir}. Skipping."
    continue
  }
  artist=`basename "${inputdir}"`
  artistdir=`echo ${artist} | \
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
  [ -d "${BEETS}/${artistdir}" ] || mkdir -p "${BEETS}/${artistdir}"
  echo "" >> ${MDN}
  echo "### ${artist}" >> ${MDN}
  echo "" >> ${MDN}
  album=
  albumartist=
  albumpath=
  cat "${TXT}" | while read line
  do
    end=
    marker=
    echo ${line} | grep "^/u/audio/Music/" > /dev/null && marker=1
    if [ "${marker}" ]
    then
      type="album"
      albumpath="${line}"
    else
      echo ${line} | grep "^END" > /dev/null && end=1
      if [ "${end}" ]
      then
        type=end
      else
        type="key"
        key=`echo ${line} | awk -F ':' ' { print $1 } ' | sed -e 's/^ *//' -e 's/ *$//'`
        case "${key}" in
          album)
            album=`echo ${line} | awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
            filename=`echo ${album} | \
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
            ;;
          albumartist)
            albumartist=`echo ${line} | awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
            ;;
          artpath)
            artpath=`echo ${line} | awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
            ;;
          genre)
            genre=`echo ${line} | awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
            ;;
          mb_albumartistid)
            mb_albumartistid=`echo ${line} | awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
            ;;
          mb_albumid)
            mb_albumid=`echo ${line} | awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
            ;;
          mb_releasegroupid)
            mb_releasegroupid=`echo ${line} | awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
            ;;
          year)
            year=`echo ${line} | awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
            ;;
          *)
            continue
            ;;
        esac
      fi
    fi
    if [ "${type}" == "album" ] || [ "${type}" == "end" ]
    then
      [ "${albumartist}" ] && [ "${album}" ] && {
        echo "- [${album}](Beets/${artistdir}/${filename}.md)" >> ${MDN}
        [ -f "${BEETS}/${artistdir}/${filename}.md" ] && {
          volume=2
          filename="${filename}_${volume}"
          while [ -f "${BEETS}/${artistdir}/${filename}.md" ]
          do
            volume=$((volume + 1))
            filename="${filename}_${volume}"
          done
        }
        catalog="Beets"
        format="Digital, Album"
        echo "---" > "${BEETS}/${artistdir}/${filename}.md"
        echo "catalog: ${catalog}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "album: ${album}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "artist: ${artist}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "format: ${format}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "albumartist: ${albumartist}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "genre: ${genre}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "mb_albumartistid: ${mb_albumartistid}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "mb_albumid: ${mb_albumid}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "mb_releasegroupid: ${mb_releasegroupid}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "year: ${year}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "---" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "# ${album}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "By **${albumartist}**" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "" >> "${BEETS}/${artistdir}/${filename}.md"
        suff=png
        [ -f "${artpath}" ] && {
          suff=`echo "${artpath}" | awk -F '.' ' { print $NF } '`
          cp "${artpath}" "../../assets/beetscovers/${artistdir}-${filename}.${suff}"
        }
        if [ -f "../../assets/beetscovers/${artistdir}-${filename}.${suff}" ]
        then
          coverurl="../../assets/beetscovers/${artistdir}-${filename}.${suff}"
        else
          coverurl=
        fi
        [ "${coverurl}" ] && {
          echo "![](${coverurl})" >> "${BEETS}/${artistdir}/${filename}.md"
          echo "" >> "${BEETS}/${artistdir}/${filename}.md"
        }
        echo "## Album Data" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "- **Catalog:** ${catalog}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "- **Format:** ${format}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "- **Album:** ${album}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "- **Artist:** ${artist}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "- **Albumartist:** ${albumartist}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "- **Genre:** ${genre}" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "- **MusicBrainz Album Artist ID:** [${mb_albumartistid}](${MBURL}/artist/${mb_albumartistid})" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "- **MusicBrainz Album ID:** [${mb_albumid}](${MBURL}/release/${mb_albumid})" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "- **MusicBrainz Release Group ID:** [${mb_releasegroupid}](${MBURL}/release-group/${mb_releasegroupid})" >> "${BEETS}/${artistdir}/${filename}.md"
        echo "- **Year:** ${year}" >> "${BEETS}/${artistdir}/${filename}.md"
        TRACKS="/tmp/tracks$$"
        beet info --library \
          --include-keys=album,albumartist,artist,catalognum,format,genre,label,length,title,track,tracktotal,year,mb_trackid \
          albumartist:"${albumartist}" \
          path:"${albumpath}" > ${TRACKS}
        echo "END" >> ${TRACKS}
        [ -f "${TRACKS}" ] || {
          echo "Missing track info for artist/album ${albumartist}/${album}. Skipping."
          continue
        }
        first=1
        cat "${TRACKS}" | while read trackline
        do
          trackend=
          trackmarker=
          echo ${trackline} | grep "^/u/audio/Music/" > /dev/null && trackmarker=1
          if [ "${trackmarker}" ]
          then
            tracktype="track"
          else
            echo ${trackline} | grep "^END" > /dev/null && trackend=1
            if [ "${trackend}" ]
            then
              tracktype=trackend
            else
              tracktype="key"
              trackkey=`echo ${trackline} | awk -F ':' ' { print $1 } ' | sed -e 's/^ *//' -e 's/ *$//'`
              case "${trackkey}" in
                album)
                  album=`echo ${trackline} | awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
                  ;;
                albumartist)
                  trackalbumartist=`echo ${trackline} | \
                    awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
                  ;;
                artist)
                  artist=`echo ${trackline} | \
                    awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
                  ;;
                genre)
                  genre=`echo ${trackline} | \
                    awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
                  ;;
                catalognum)
                  catalognum=`echo ${trackline} | \
                    awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
                  ;;
                format)
                  format=`echo ${trackline} | \
                    awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
                  ;;
                label)
                  label=`echo ${trackline} | \
                    awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
                  ;;
                length)
                  length=`echo ${trackline} | \
                    awk '{for(i=2;i<=NF;i++){ printf("%s",( (i>2) ? OFS : "" ) $i) } ;}'`
                  ;;
                mb_trackid)
                  mb_trackid=`echo ${trackline} | \
                    awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
                  ;;
                title)
                  title=`echo ${trackline} | \
                    awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
                  ;;
                track)
                  track=`echo ${trackline} | \
                    awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
                  ;;
                tracktotal)
                  tracktotal=`echo ${trackline} | \
                    awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
                  ;;
                year)
                  year=`echo ${trackline} | \
                    awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
                  ;;
                *)
                  continue
                  ;;
              esac
            fi
          fi
          if [ "${tracktype}" == "track" ] || [ "${tracktype}" == "trackend" ]
          then
            [ "${trackalbumartist}" ] && {
              [ "${first}" ] && {
                echo "- **Catalog #:** ${catalognum}" >> "${BEETS}/${artistdir}/${filename}.md"
                echo "- **Label:** ${label}" >> "${BEETS}/${artistdir}/${filename}.md"
                echo "- **Total Tracks:** ${tracktotal}" >> "${BEETS}/${artistdir}/${filename}.md"
                echo "" >> "${BEETS}/${artistdir}/${filename}.md"
                echo "## Album Tracks" >> "${BEETS}/${artistdir}/${filename}.md"
                echo "" >> "${BEETS}/${artistdir}/${filename}.md"
                first=
              }
              echo "### Track ${track} - ${title}" >> "${BEETS}/${artistdir}/${filename}.md"
              echo "" >> "${BEETS}/${artistdir}/${filename}.md"
              echo "- **Artist:** ${artist}" >> "${BEETS}/${artistdir}/${filename}.md"
              echo "- **Format:** ${format}" >> "${BEETS}/${artistdir}/${filename}.md"
              echo "- **Genre:** ${genre}" >> "${BEETS}/${artistdir}/${filename}.md"
              echo "- **Length:** ${length}" >> "${BEETS}/${artistdir}/${filename}.md"
              echo "- **MusicBrainz Track ID:** [${mb_trackid}](${MBURL}/recording/${mb_trackid})" >> "${BEETS}/${artistdir}/${filename}.md"
              echo "- **Title:** ${title}" >> "${BEETS}/${artistdir}/${filename}.md"
              echo "- **Track:** ${track}" >> "${BEETS}/${artistdir}/${filename}.md"
              echo "- **Year:** ${year}" >> "${BEETS}/${artistdir}/${filename}.md"
              echo "" >> "${BEETS}/${artistdir}/${filename}.md"
            }
          else
            continue
          fi
        done
        rm -f ${TRACKS}
      }
    else
      continue
    fi
  done
done
```

</Details>

## Books_library

My books are catalogued in Goodreads. To export a Goodreads book library, login to Goodreads and click `My Books`. Scroll down and click `Import and export` on the left. Click the `Export` button and wait for Goodreads to generate a link to your library export CSV file. Download that file by right clicking the generated link and saving to local disk.

The following scripts generate Markdown format files for each of the books in the downloaded CSV format Goodreads export, download the Goodreads RSS feed XML for specified bookshelves, and create various indexes of the generated Obsidian vault. Click the arrow to the left of the details link to expand or collapse each script.

<Details markdown="block">

Script to generate Markdown format files for each of the books in the downloaded CSV format Goodreads export.

### [Tools/Books/csv2md](Tools/Books/csv2md.md) (click to collapse/expand)

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

</Details>

<Details markdown="block">

Unfortunately, the Goodreads CSV export does not include the book cover images. If you want the links to the book covers for your library in Goodreads they are available in the RSS feeds for the Goodread shelves you have created. In Goodreads, go to a shelf (`My Books` then click on a shelf listed under `Bookshelves`) and at the bottom right corner there should be an RSS feed icon. Right click the RSS icon and copy the link. The RSS feed link should look something like `https://www.goodreads.com/review/list_rss/XXXXXXX?key=YYYsomelongstringofdigitsandnumbersYYYE&shelf=anthologies` where `XXXXXXX` and `YYYblablablaYYY` are private codes representing your Goodreads ID and the shelf key. Take note of the last component of the RSS feed URL, the part in the example above with `&shelf=anthologies`. The `anthologies` part is the name of the shelf, in your case it will be something else, whatever the name of the shelf you selected.

This script makes it easier to download the bookshelves RSS feed XML data. All you need to use this script is the first part of any RSS feed URL in your Goodreads bookshelves. In the example above that would be `https://www.goodreads.com/review/list_rss/XXXXXXX?key=YYYsomelongstringofdigitsandnumbersYYYE&shelf=`. That is, everything but the shelf name.

Replace the `baseurl` URL in the following script with your Goodreads base URL from an RSS feed URL of one of your shelves. Also replace the list of Goodreads shelves below in the variable `shelves` with a list of the shelves in your Goodreads library that you wish to export to XML.

After configuring the script with your private base Goodreads RSS feed URL and the list of your Goodreads bookshelves, simply run the script and it will download all the XML exports for the listed Goodreads shelves. These contain the links to the book cover images.

**[Note:]** Goodreads RSS feeds only include the first 100 entries of a shelf. I had to create new shelves and split any existing Goodreads shelves over 100 entries in size up into multiple shelves. What a pain. So, everything cannot be automated because services are lame.

The script used to generate the Markdown from Goodreads shelf XML RSS feeds:

### [Tools/Books/get_goodreads_xml.sh](Tools/Books/get_goodreads_xml.sh.md) (click to collapse/expand)

```shell

#!/bin/bash

# Enter urls to your goodreads rss feed below.
# You can find it by navigating to one of your goodreads shelves and
# clicking the "RSS" button at the bottom of the page.

baseurl="https://www.goodreads.com/review/list_rss/XXXXXXX?key=YYYsomelongstringofdigitsandnumbersYYYE&shelf="

shelves="anthologies biography bob brautigan conklin essays farmer fiction \
         huxley leary literature mathematics mcmurtry murakami nonfiction \
         novels p-k-dick palahniuk philosophy poetry reference robbins science \
         science-fiction short-stories steinbeck vonnegut currently-reading \
         read to-read"

# Enter the path to your Vault or XML download folder
vaultpath="/home/ronnie/Documents/Obsidian/Books/Tools/data/xml"

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

</Details>

<Details markdown="block">

Generate various indexes into the Markdown format files created in the Obsidian vault with the previous scripts. This script can generate lists of books sorted by author or title in list or table format.

### [Tools/Books/mkbooks](Tools/Books/mkbooks.md) (click to collapse/expand)

```shell

#!/bin/bash

VAULT="${HOME}/Documents/Obsidian/Obsidian-Media-Vault"
TOP="${VAULT}/Books"

usage() {
  printf "\nUsage: mkbooks [-A] [-T] [-f] [-p /path/to/Books] [-t] [-u]"
  printf "\nWhere:"
  printf "\n\t-A indicates sort by Author"
  printf "\n\t-T indicates sort by Title (default)"
  printf "\n\t-f indicates overwrite any pre-existing Books index markdown"
  printf "\n\t-p /path/to/Books specifies the full path to the Books folder"
  printf "\n\t(default: ${HOME}/Documents/Obsidian/Obsidian-Media-Vault/Books)"
  printf "\n\t-t indicates create a table rather than listing"
  printf "\n\t-u displays this usage message and exits\n\n"
  exit 1
}

mktable=
overwrite=
sortorder="title"

while getopts "ATfp:tu" flag; do
    case $flag in
        A)
            sortorder="author"
            ;;
        T)
            sortorder="title"
            ;;
        f)
            overwrite=1
            ;;
        p)
            TOP="${OPTARG}"
            ;;
        t)
            mktable=1
            numcols=1
            ;;
        u)
            usage
            ;;
    esac
done
shift $(( OPTIND - 1 ))

[ -d "${TOP}" ] || {
  echo "$TOP does not exist or is not a directory. Exiting."
  exit 1
}

if [ "${mktable}" ]
then
  if [ "${sortorder}" == "title" ]
  then
    book_index="Table_of_Books_by_Title"
  else
    book_index="Table_of_Books_by_Author"
  fi
else
  if [ "${sortorder}" == "title" ]
  then
    book_index="Books_by_Title"
  else
    book_index="Books_by_Author"
  fi
fi

cd "${TOP}"

[ "${overwrite}" ] && rm -f ${VAULT}/${book_index}.md

if [ -f ${VAULT}/${book_index}.md ]
then
  echo "${book_index}.md already exists. Use '-f' to overwrite an existing index."
  echo "Exiting without changes."
  exit 1
else
  echo "# Books" > ${VAULT}/${book_index}.md
  echo "" >> ${VAULT}/${book_index}.md
  if [ "${mktable}" ]
  then
    if [ "${sortorder}" == "title" ]
    then
      echo "## Table of Books by Title" >> ${VAULT}/${book_index}.md
    else
      echo "## Table of Books by Author" >> ${VAULT}/${book_index}.md
    fi
  else
    if [ "${sortorder}" == "title" ]
    then
      echo "## Index of Books by Title" >> ${VAULT}/${book_index}.md
    else
      echo "## Index of Books by Author" >> ${VAULT}/${book_index}.md
    fi
    echo "" >> ${VAULT}/${book_index}.md
    echo "| **[A](#a)** | **[B](#b)** | **[C](#c)** | **[D](#d)** | **[E](#e)** | **[F](#f)** | **[G](#g)** | **[H](#h)** | **[I](#i)** | **[J](#j)** | **[K](#k)** | **[L](#l)** | **[M](#m)** | **[N](#n)** | **[O](#o)** | **[P](#p)** | **[Q](#q)** | **[R](#r)** | **[S](#s)** | **[T](#t)** | **[U](#u)** | **[V](#v)** | **[W](#w)** | **[X](#x)** | **[Y](#y)** | **[Z](#z)** |" >> ${VAULT}/${book_index}.md
    echo "|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|" >> ${VAULT}/${book_index}.md
    echo "" >> ${VAULT}/${book_index}.md
  fi
  echo "" >> ${VAULT}/${book_index}.md
  if [ "${mktable}" ]
  then
    if [ "${sortorder}" == "title" ]
    then
      echo "| **Title by Author** | **Title by Author** | **Title by Author** | **Title by Author** | **Title by Author** |" >> ${VAULT}/${book_index}.md
    else
      echo "| **Author: Title** | **Author: Title** | **Author: Title** | **Author: Title** | **Author: Title** |" >> ${VAULT}/${book_index}.md
    fi
    echo "|--|--|--|--|--|" >> ${VAULT}/${book_index}.md
  else
    if [ "${sortorder}" == "title" ]
    then
      heading="0-9"
    else
      heading="A"
      author_heading=
    fi
    echo "### ${heading}" >> ${VAULT}/${book_index}.md
    echo "" >> ${VAULT}/${book_index}.md
  fi

  if [ "${mktable}" ]
  then
    if [ "${sortorder}" == "title" ]
    then
      ls -1 */*.md | sort -k 2 -t'/' > /tmp/books$$
      while read book
      do
        author=`echo ${book} | awk -F '/' ' { print $1 } '`
        filename=`echo ${book} | awk -F '/' ' { print $2 } ' | sed -e "s/\.md//"`
        [ "${author}" == "${filename}" ] && continue
        authorname=`grep "author:" ${book} | head -1 | \
          awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
        [ "${authorname}" ] || {
          echo "${book} needs an author: tag. Skipping."
          continue
        }
        title=`grep "title:" ${book} | awk -F ':' ' { print $2 } ' | \
          sed -e 's/^ *//' -e 's/ *$//' -e "s/^\"//" -e "s/\"$//"`
        [ "${title}" ] || {
          echo "${book} needs a title: tag. Skipping."
          continue
        }
        if [ ${numcols} -gt 4 ]
        then
          printf "| [${title}](Books/${book}) by ${authorname} |\n" >> ${VAULT}/${book_index}.md
          numcols=1
        else
          printf "| [${title}](Books/${book}) by ${authorname} " >> ${VAULT}/${book_index}.md
          numcols=$((numcols+1))
        fi
      done < <(cat /tmp/books$$)

      while [ ${numcols} -lt 5 ]
      do
        printf "| " >> ${VAULT}/${book_index}.md
        numcols=$((numcols+1))
      done
      printf "|\n" >> ${VAULT}/${book_index}.md
      rm -f /tmp/books$$
    else
      for author in *
      do
        [ "${author}" == "*" ] && continue
        [ -d "${author}" ] || continue
        cd "${author}"
        authorname=
        for book in *.md
        do
          [ "${book}" == "*.md" ] && continue
          [ "${book}" == "${author}.md" ] && continue
          [ "${authorname}" ] || {
            authorname=`grep "author:" ${book} | head -1 | \
              awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
          }
          title=`grep "title:" ${book} | awk -F ':' ' { print $2 } ' | \
            sed -e 's/^ *//' -e 's/ *$//' -e "s/^\"//" -e "s/\"$//"`
          if [ ${numcols} -gt 4 ]
          then
            printf "| ${authorname}: [${title}](Books/${author}/${book}) |\n" >> ${VAULT}/${book_index}.md
            numcols=1
          else
            printf "| ${authorname}: [${title}](Books/${author}/${book}) " >> ${VAULT}/${book_index}.md
            numcols=$((numcols+1))
          fi
        done
        cd ..
      done

      while [ ${numcols} -lt 5 ]
      do
        printf "| " >> ${VAULT}/${book_index}.md
        numcols=$((numcols+1))
      done
      printf "|\n" >> ${VAULT}/${book_index}.md
    fi
  else
    if [ "${sortorder}" == "title" ]
    then
      ls -1 */*.md | sort -k 2 -t'/' > /tmp/books$$
      removetmp=
    else
      mkdir ../../tmp$$
      removetmp=1
      declare -A author_array
      for bookmd in */*.md
      do
        author=`echo ${bookmd} | awk -F '/' ' { print $1 } '`
        filename=`echo ${bookmd} | awk -F '/' ' { print $2 } '`
        [ "${author}.md" == "${filename}" ] && continue
        authorsort=`grep "authorsort:" ${bookmd} | head -1 | \
          awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//' -e "s/,//" -e "s/ /_/g"`
        [ "${authorsort}" ] || {
          echo "${bookmd} needs an authorsort: tag. Skipping."
          continue
        }
        # Make a duplicate Books folder with new filenames based on author sort names
        [ -d "../../tmp$$/${authorsort}" ] || mkdir -p "../../tmp$$/${authorsort}"
        cp ${bookmd} "../../tmp$$/${authorsort}"
        author_array["${authorsort}/${filename}"]="${bookmd}"
      done
      cd "../../tmp$$"
      ls -1 */*.md | sort -k 1 -t'/' > /tmp/books$$
    fi
    while read book
    do
      author=`echo ${book} | awk -F '/' ' { print $1 } '`
      filename=`echo ${book} | awk -F '/' ' { print $2 } ' | sed -e "s/\.md//"`
      [ "${author}" == "${filename}" ] && continue
      if [ "${sortorder}" == "title" ]
      then
        authorname=`grep "author:" ${book} | head -1 | \
          awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
      else
        authorname=`grep "authorsort:" ${book} | head -1 | \
          awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
      fi
      [ "${authorname}" ] || {
        echo "${book} needs an author: tag. Skipping."
        continue
      }
      title=`grep "title:" ${book} | awk -F ':' ' { print $2 } ' | \
        sed -e 's/^ *//' -e 's/ *$//' -e "s/^\"//" -e "s/\"$//"`
      [ "${title}" ] || {
        echo "${book} needs a title: tag. Skipping."
        continue
      }
      if [ "${sortorder}" == "title" ]
      then
        first=${title:0:1}
      else
        first=${authorname:0:1}
      fi
      if [ "${heading}" == "0-9" ]
      then
        [ "${first}" -eq "${first}" ] 2> /dev/null || {
          heading=${first}
          echo "" >> ${VAULT}/${book_index}.md
          echo "### ${heading}" >> ${VAULT}/${book_index}.md
          echo "" >> ${VAULT}/${book_index}.md
        }
      else
        [ "${first}" == "${heading}" ] || {
          heading=${first}
          echo "" >> ${VAULT}/${book_index}.md
          echo "### ${heading}" >> ${VAULT}/${book_index}.md
          echo "" >> ${VAULT}/${book_index}.md
        }
      fi
      if [ "${sortorder}" == "title" ]
      then
        echo "- [${title}](Books/${book}) by ${authorname}" >> ${VAULT}/${book_index}.md
      else
        [ "${authorname}" == "${author_heading}" ] || {
          author_heading=${authorname}
          echo "" >> ${VAULT}/${book_index}.md
          echo "#### ${author_heading}" >> ${VAULT}/${book_index}.md
          echo "" >> ${VAULT}/${book_index}.md
        }
        booklink="${author_array[${book}]}"
        echo "- [${title}](Books/${booklink})" >> ${VAULT}/${book_index}.md
      fi
    done < <(cat /tmp/books$$)
    rm -f /tmp/books$$
    [ "${removetmp}" ] && {
      cd ..
      [ -d tmp$$ ] && rm -rf tmp$$
    }
  fi
fi

```

</Details>

<Details markdown="block">

Generate markdown for each of the authors with a link to their Wikipedia article and links to their books. Also generate a markdown document with a table of all authors.

### [Tools/Books/mkauthors](Tools/Books/mkauthors.md) (click to collapse/expand)

```shell

#!/bin/bash

TOP="${HOME}/Documents/Obsidian/Obsidian-Media-Vault/Books"

[ -d "${TOP}" ] || {
  echo "$TOP does not exist or is not a directory. Exiting."
  exit 1
}

cd "${TOP}"

mkauthors=
numcols=1
overwrite=
remove=
[ "$1" == "-f" ] && overwrite=1
[ "$1" == "-r" ] && remove=1

[ "${remove}" ] || [ "${overwrite}" ] && rm -f ../Authors.md

[ -f ../Authors.md ] || {
  mkauthors=1
  echo "# Authors" > ../Authors.md
  echo "" >> ../Authors.md
  echo "## List of Authors in Vault" >> ../Authors.md
  echo "" >> ../Authors.md
  echo "| **Author Name** | **Author Name** | **Author Name** | **Author Name** | **Author Name** |" >> ../Authors.md
  echo "|--|--|--|--|--|" >> ../Authors.md
}

for author in *
do
  [ "${author}" == "*" ] && continue
  [ -d "${author}" ] || continue
  [ "${remove}" ] && {
    rm -f ${author}/${author}.md
    continue
  }
  if [ "${overwrite}" ]
  then
    rm -f ${author}/${author}.md
  else
    [ -f ${author}/${author}.md ] && continue
  fi
  cd "${author}"
  echo "" > /tmp/sa$$
  echo "## Books" >> /tmp/sa$$
  echo "" >> /tmp/sa$$
  authorname=
  for book in *.md
  do
    [ "${book}" == "*.md" ] && continue
    [ "${book}" == "${author}.md" ] && continue
    [ "${authorname}" ] || {
      authorname=`grep "author:" ${book} | head -1 | \
        awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
    }
    title=`grep "title:" ${book} | awk -F ':' ' { print $2 } ' | \
      sed -e 's/^ *//' -e 's/ *$//' -e "s/^\"//" -e "s/\"$//"`
    echo "- [${title}](${book})" >> /tmp/sa$$
  done
  wikilink=`echo ${authorname} | sed -e "s/ /_/g"`
  echo "# ${authorname}" > /tmp/au$$
  echo "" >> /tmp/au$$
  echo "[Wikipedia entry](https://en.wikipedia.org/wiki/${wikilink})" >> /tmp/au$$
  cat /tmp/au$$ /tmp/sa$$ > ${author}.md
  rm -f /tmp/au$$ /tmp/sa$$
  cd ..
  [ "${mkauthors}" ] && {
    [ -f "${author}/${author}.md" ] && {
      if [ ${numcols} -gt 4 ]
      then
        printf "| [${authorname}](Books/${author}/${author}.md) |\n" >> ../Authors.md
        numcols=1
      else
        printf "| [${authorname}](Books/${author}/${author}.md) " >> ../Authors.md
        numcols=$((numcols+1))
      fi
    }
  }
done

[ "${mkauthors}" ] && {
  while [ ${numcols} -lt 4 ]
  do
    printf "| " >> ../Authors.md
    numcols=$((numcols+1))
  done
  printf "|\n" >> ../Authors.md
}

```

</Details>

## Vinyl_library

My vinyl records are catalogued in [Discogs](https://www.discogs.com). To export a Discogs library, login to Discogs and click the `Dashboard` icon or your profile dropdown and `Dashboard`. At your Discogs dashboard, which should be something like [https://www.discogs.com/my](https://www.discogs.com/my), click `Export` at the top of the dashboard. In the `What to export` dropdown select `Collection`. Click the `Request Data Export` button and wait for Discogs to generate the export. Download the generated Discogs CSV export file by clicking the `Download` button.

The following scripts generate Markdown format files for each of the records in the downloaded CSV format Discogs export and create various indexes of the generated Obsidian vault. Click the arrow to the left of the details link to expand or collapse each script.

<Details markdown="block">

Script to generate Markdown format files for each of the records in the downloaded CSV format Discogs export. You will need to modify this script, changing `data/doctorfree-collection-discogs.csv` to the location of your downloaded Discogs CSV export.

### [Tools/Vinyl/mkrecords](Tools/Vinyl/mkrecords.md) (click to collapse/expand)

```shell

#!/bin/bash
#
# Columns:
# 1: Catalog#
# 2: Artist
# 3: Title
# 4: Label
# 5: Format
# 6: Rating
# 7: Released
# 8: release_id
# 9: CollectionFolder
#10: Date Added
#11: Collection Media Condition
#12: Collection Sleeve Condition
#13: Collection Speed
#14: Collection Weight
#15: Collection Notes

RECORDS="../../Vinyl"
update=
numknown=1
[ "$1" == "-u" ] && update=1

[ -d ${RECORDS} ] || mkdir ${RECORDS}

cat data/doctorfree-collection-discogs.csv | while read line
do
  if [ "${first}" ]
  then
    title=`echo ${line} | csvcut -c 3`
    releaseid=`echo ${line} | csvcut -c 8 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
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
    [ "${filename}" ] || {
      if [ "${releaseid}" ]
      then
        filename="Unknown-${releaseid}"
      else
        filename="Unknown-${numknown}"
        $((numknown + 1))
      fi
    }
    echo "Processing ${filename}"
    artist=`echo ${line} | csvcut -c 2`
    artistdir=`echo ${artist} | \
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

    [ -f ${RECORDS}/${artistdir}/${filename}.md ] && continue

    # Download album cover art
    [ -f "../../assets/albumcovers/${artistdir}-${filename}.png" ] || {
      echo "Downloading cover art for ${artist} - ${title}"
      sacad "${artist}" "${title}" 600 \
        ../../assets/albumcovers/${artistdir}-${filename}.png 2> /dev/null
    }
    [ -d ${RECORDS}/${artistdir} ] || mkdir ${RECORDS}/${artistdir}
    catalog=`echo ${line} | csvcut -c 1 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    label=`echo ${line} | csvcut -c 4 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    format=`echo ${line} | csvcut -c 5 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    rating=`echo ${line} | csvcut -c 6 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    released=`echo ${line} | csvcut -c 7 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    mediacondition=`echo ${line} | csvcut -c 11 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    sleevecondition=`echo ${line} | csvcut -c 12 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    speed=`echo ${line} | csvcut -c 13 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    weight=`echo ${line} | csvcut -c 14 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    notes=`echo ${line} | csvcut -c 15 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    echo "---" > ${RECORDS}/${artistdir}/${filename}.md
    echo "catalog: ${catalog}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "title: ${title}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "artist: ${artist}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "label: ${label}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "format: ${format}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "rating: ${rating}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "released: ${released}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "releaseid: ${releaseid}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "mediacondition: ${mediacondition}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "sleevecondition: ${sleevecondition}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "speed: ${speed}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "weight: ${weight}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "notes: ${notes}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "---" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "# ${title}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "By ${artist}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "" >> ${RECORDS}/${artistdir}/${filename}.md
    if [ -f "../../assets/albumcovers/${artistdir}-${filename}.png" ]
    then
      coverurl="../../assets/albumcovers/${artistdir}-${filename}.png"
    else
      coverurl=
    fi
    [ "${coverurl}" ] && {
      echo "![](${coverurl})" >> ${RECORDS}/${artistdir}/${filename}.md
      echo "" >> ${RECORDS}/${artistdir}/${filename}.md
    }
    echo "## Album Data" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "" >> ${RECORDS}/${artistdir}/${filename}.md
    [ "${releaseid}" ] && {
      artisturl=`echo "${artist}" | sed -e "s/ /-/g"`
      titleurl=`echo "${title}" | sed -e "s/ /-/g"`
      releaseurl="https://www.discogs.com/release/${releaseid}-${artisturl}-${titleurl}"
      echo "[Discogs URL](${releaseurl})" >> ${RECORDS}/${artistdir}/${filename}.md
      echo "" >> ${RECORDS}/${artistdir}/${filename}.md
    }
    echo "" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "- Catalog #: ${catalog}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "- Label: ${label}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "- Format: ${format}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "- Rating: ${rating}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "- Released: ${released}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "- Release ID: ${releaseid}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "- Media condition: ${mediacondition}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "- Sleeve condition: ${sleevecondition}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "- Speed: ${speed}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "- Weight: ${weight}" >> ${RECORDS}/${artistdir}/${filename}.md
    echo "" >> ${RECORDS}/${artistdir}/${filename}.md
    [ "${notes}" ] && {
      echo "## Notes" >> ${RECORDS}/${artistdir}/${filename}.md
      echo "" >> ${RECORDS}/${artistdir}/${filename}.md
      echo "${notes}" >> ${RECORDS}/${artistdir}/${filename}.md
      echo "" >> ${RECORDS}/${artistdir}/${filename}.md
    }
  else
    first=1
  fi
done

```

</Details>

<Details markdown="block">

Generate various indexes into the Markdown format files created in the Obsidian vault with the previous script. This script can generate lists of records sorted by artist or title in list or table format.

### [Tools/Vinyl/mkvinyl](Tools/Vinyl/mkvinyl.md) (click to collapse/expand)

```shell

#!/bin/bash

VAULT="${HOME}/Documents/Obsidian/Obsidian-Media-Vault"
TOP="${VAULT}/Vinyl"

usage() {
  printf "\nUsage: mkvinyl [-A] [-T] [-f] [-p /path/to/Vinyl] [-t] [-u]"
  printf "\nWhere:"
  printf "\n\t-A indicates sort by Artist"
  printf "\n\t-T indicates sort by Title (default)"
  printf "\n\t-f indicates overwrite any pre-existing Vinyl index markdown"
  printf "\n\t-p /path/to/Vinyl specifies the full path to the Vinyl folder"
  printf "\n\t(default: ${HOME}/Documents/Obsidian/Obsidian-Media-Vault/Vinyl)"
  printf "\n\t-t indicates create a table rather than listing"
  printf "\n\t-u displays this usage message and exits\n\n"
  exit 1
}

mktable=
overwrite=
sortorder="title"

while getopts "ATfp:tu" flag; do
    case $flag in
        A)
            sortorder="artist"
            ;;
        T)
            sortorder="title"
            ;;
        f)
            overwrite=1
            ;;
        p)
            TOP="${OPTARG}"
            ;;
        t)
            mktable=1
            numcols=1
            ;;
        u)
            usage
            ;;
    esac
done
shift $(( OPTIND - 1 ))

[ -d "${TOP}" ] || {
  echo "$TOP does not exist or is not a directory. Exiting."
  exit 1
}

if [ "${mktable}" ]
then
  if [ "${sortorder}" == "title" ]
  then
    vinyl_index="Table_of_Vinyl_by_Title"
  else
    vinyl_index="Table_of_Vinyl_by_Artist"
  fi
else
  if [ "${sortorder}" == "title" ]
  then
    vinyl_index="Vinyl_by_Title"
  else
    vinyl_index="Vinyl_by_Artist"
  fi
fi

cd "${TOP}"

[ "${overwrite}" ] && rm -f ${VAULT}/${vinyl_index}.md

if [ -f ${VAULT}/${vinyl_index}.md ]
then
  echo "${vinyl_index}.md already exists. Use '-f' to overwrite an existing index."
  echo "Exiting without changes."
  exit 1
else
  echo "# Vinyl" > ${VAULT}/${vinyl_index}.md
  echo "" >> ${VAULT}/${vinyl_index}.md
  if [ "${mktable}" ]
  then
    if [ "${sortorder}" == "title" ]
    then
      echo "## Table of Vinyl by Title" >> ${VAULT}/${vinyl_index}.md
    else
      echo "## Table of Vinyl by Artist" >> ${VAULT}/${vinyl_index}.md
    fi
  else
    if [ "${sortorder}" == "title" ]
    then
      echo "## Index of Vinyl by Title" >> ${VAULT}/${vinyl_index}.md
    else
      echo "## Index of Vinyl by Artist" >> ${VAULT}/${vinyl_index}.md
    fi
    echo "" >> ${VAULT}/${vinyl_index}.md
    echo "| **[A](#a)** | **[B](#b)** | **[C](#c)** | **[D](#d)** | **[E](#e)** | **[F](#f)** | **[G](#g)** | **[H](#h)** | **[I](#i)** | **[J](#j)** | **[K](#k)** | **[L](#l)** | **[M](#m)** | **[N](#n)** | **[O](#o)** | **[P](#p)** | **[Q](#q)** | **[R](#r)** | **[S](#s)** | **[T](#t)** | **[U](#u)** | **[V](#v)** | **[W](#w)** | **[X](#x)** | **[Y](#y)** | **[Z](#z)** |" >> ${VAULT}/${vinyl_index}.md
    echo "|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|" >> ${VAULT}/${vinyl_index}.md
    echo "" >> ${VAULT}/${vinyl_index}.md
  fi
  echo "" >> ${VAULT}/${vinyl_index}.md
  if [ "${mktable}" ]
  then
    if [ "${sortorder}" == "title" ]
    then
      echo "| **Title by Artist** | **Title by Artist** | **Title by Artist** | **Title by Artist** | **Title by Artist** |" >> ${VAULT}/${vinyl_index}.md
    else
      echo "| **Artist: Title** | **Artist: Title** | **Artist: Title** | **Artist: Title** | **Artist: Title** |" >> ${VAULT}/${vinyl_index}.md
    fi
    echo "|--|--|--|--|--|" >> ${VAULT}/${vinyl_index}.md
  else
    heading="0-9"
    artist_heading=
    echo "### ${heading}" >> ${VAULT}/${vinyl_index}.md
    echo "" >> ${VAULT}/${vinyl_index}.md
  fi

  if [ "${mktable}" ]
  then
    if [ "${sortorder}" == "title" ]
    then
      ls -1 */*.md | sort -k 2 -t'/' > /tmp/vinyls$$
      while read vinyl
      do
        artist=`echo ${vinyl} | awk -F '/' ' { print $1 } '`
        filename=`echo ${vinyl} | awk -F '/' ' { print $2 } ' | sed -e "s/\.md//"`
        [ "${artist}" == "${filename}" ] && continue
        artistname=`grep "artist:" ${vinyl} | head -1 | \
          awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
        [ "${artistname}" ] || {
          echo "${vinyl} needs an artist: tag. Skipping."
          continue
        }
        title=`grep "title:" ${vinyl} | awk -F ':' ' { print $2 } ' | \
          sed -e 's/^ *//' -e 's/ *$//' -e "s/^\"//" -e "s/\"$//"`
        [ "${title}" ] || {
          echo "${vinyl} needs a title: tag. Skipping."
          continue
        }
        if [ ${numcols} -gt 4 ]
        then
          printf "| [${title}](Vinyl/${vinyl}) by ${artistname} |\n" >> ${VAULT}/${vinyl_index}.md
          numcols=1
        else
          printf "| [${title}](Vinyl/${vinyl}) by ${artistname} " >> ${VAULT}/${vinyl_index}.md
          numcols=$((numcols+1))
        fi
      done < <(cat /tmp/vinyls$$)

      while [ ${numcols} -lt 5 ]
      do
        printf "| " >> ${VAULT}/${vinyl_index}.md
        numcols=$((numcols+1))
      done
      printf "|\n" >> ${VAULT}/${vinyl_index}.md
      rm -f /tmp/vinyls$$
    else
      for artist in *
      do
        [ "${artist}" == "*" ] && continue
        [ -d "${artist}" ] || continue
        cd "${artist}"
        artistname=
        for vinyl in *.md
        do
          [ "${vinyl}" == "*.md" ] && continue
          [ "${vinyl}" == "${artist}.md" ] && continue
          [ "${artistname}" ] || {
            artistname=`grep "artist:" ${vinyl} | head -1 | \
              awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
          }
          title=`grep "title:" ${vinyl} | awk -F ':' ' { print $2 } ' | \
            sed -e 's/^ *//' -e 's/ *$//' -e "s/^\"//" -e "s/\"$//"`
          if [ ${numcols} -gt 4 ]
          then
            printf "| ${artistname}: [${title}](Vinyl/${artist}/${vinyl}) |\n" >> ${VAULT}/${vinyl_index}.md
            numcols=1
          else
            printf "| ${artistname}: [${title}](Vinyl/${artist}/${vinyl}) " >> ${VAULT}/${vinyl_index}.md
            numcols=$((numcols+1))
          fi
        done
        cd ..
      done

      while [ ${numcols} -lt 5 ]
      do
        printf "| " >> ${VAULT}/${vinyl_index}.md
        numcols=$((numcols+1))
      done
      printf "|\n" >> ${VAULT}/${vinyl_index}.md
    fi
  else
    if [ "${sortorder}" == "title" ]
    then
      ls -1 */*.md | sort -k 2 -t'/' > /tmp/vinyls$$
    else
      ls -1 */*.md | sort -k 1 -t'/' > /tmp/vinyls$$
    fi
    while read vinyl
    do
      artist=`echo ${vinyl} | awk -F '/' ' { print $1 } '`
      filename=`echo ${vinyl} | awk -F '/' ' { print $2 } ' | sed -e "s/\.md//"`
      [ "${artist}" == "${filename}" ] && continue
      artistname=`grep "artist:" ${vinyl} | head -1 | \
        awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
      [ "${artistname}" ] || {
        echo "${vinyl} needs an artist: tag. Skipping."
        continue
      }
      title=`grep "title:" ${vinyl} | awk -F ':' ' { print $2 } ' | \
        sed -e 's/^ *//' -e 's/ *$//' -e "s/^\"//" -e "s/\"$//"`
      [ "${title}" ] || {
        echo "${vinyl} needs a title: tag. Skipping."
        continue
      }
      if [ "${sortorder}" == "title" ]
      then
        first=${title:0:1}
      else
        first=${artistname:0:1}
      fi
      if [ "${heading}" == "0-9" ]
      then
        [ "${first}" -eq "${first}" ] 2> /dev/null || {
          [ "${first}" == "#" ] || {
            [ "${first}" == "?" ] || {
              [ "${first}" == "_" ] || {
                heading=${first}
                echo "" >> ${VAULT}/${vinyl_index}.md
                echo "### ${heading}" >> ${VAULT}/${vinyl_index}.md
                echo "" >> ${VAULT}/${vinyl_index}.md
              }
            }
          }
        }
      else
        [ "${first}" == "${heading}" ] || {
          heading=${first}
          echo "" >> ${VAULT}/${vinyl_index}.md
          echo "### ${heading}" >> ${VAULT}/${vinyl_index}.md
          echo "" >> ${VAULT}/${vinyl_index}.md
        }
      fi
      if [ "${sortorder}" == "title" ]
      then
        echo "- [${title}](Vinyl/${vinyl}) by **${artistname}**" >> ${VAULT}/${vinyl_index}.md
      else
        [ "${artistname}" == "${artist_heading}" ] || {
          artist_heading=${artistname}
          echo "" >> ${VAULT}/${vinyl_index}.md
          echo "#### ${artist_heading}" >> ${VAULT}/${vinyl_index}.md
          echo "" >> ${VAULT}/${vinyl_index}.md
        }
        echo "- [${title}](Vinyl/${vinyl})" >> ${VAULT}/${vinyl_index}.md
      fi
    done < <(cat /tmp/vinyls$$)
    rm -f /tmp/vinyls$$
  fi
fi

```

</Details>

<Details markdown="block">

Generate markdown for each of the vinyl artists with a link to their Wikipedia article and links to their record releases. Also generate a markdown document with a table of all vinyl artists.

### [Tools/Vinyl/mkartists](Tools/Vinyl/mkartists.md) (click to collapse/expand)

```shell

#!/bin/bash

TOP="${HOME}/Documents/Obsidian/Obsidian-Media-Vault/Vinyl"
OUT="Vinyl_Artists.md"

[ -d "${TOP}" ] || {
  echo "$TOP does not exist or is not a directory. Exiting."
  exit 1
}

cd "${TOP}"

mkartists=
numcols=1
overwrite=
remove=
[ "$1" == "-f" ] && overwrite=1
[ "$1" == "-r" ] && remove=1

[ "${remove}" ] || [ "${overwrite}" ] && rm -f ../${OUT}

[ -f ../${OUT} ] || {
  mkartists=1
  echo "# Vinyl Artists" > ../${OUT}
  echo "" >> ../${OUT}
  echo "## List of Vinyl Artists in Vault" >> ../${OUT}
  echo "" >> ../${OUT}
  echo "| **Artist Name** | **Artist Name** | **Artist Name** | **Artist Name** | **Artist Name** |" >> ../${OUT}
  echo "|--|--|--|--|--|" >> ../${OUT}
}

for artist in *
do
  [ "${artist}" == "*" ] && continue
  [ -d "${artist}" ] || continue
  album="${artist}"
  grep "title:" ${artist}/${artist}.md > /dev/null && album="${artist}_index"
  [ "${remove}" ] && {
    rm -f ${artist}/${album}.md
    continue
  }
  if [ "${overwrite}" ]
  then
    grep "title:" ${artist}/${album}.md > /dev/null && continue
    rm -f ${artist}/${album}.md
  else
    [ -f ${artist}/${album}.md ] && continue
  fi
  cd "${artist}"
  echo "" > /tmp/sa$$
  echo "## Vinyl" >> /tmp/sa$$
  echo "" >> /tmp/sa$$
  artistname=
  for disc in *.md
  do
    [ "${disc}" == "*.md" ] && continue
    [ "${disc}" == "${album}.md" ] && continue
    [ "${artistname}" ] || {
      artistname=`grep "artist:" ${disc} | head -1 | \
        awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
    }
    title=`grep "title:" ${disc} | awk -F ':' ' { print $2 } ' | \
      sed -e 's/^ *//' -e 's/ *$//' -e "s/^\"//" -e "s/\"$//"`
    echo "- [${title}](${disc})" >> /tmp/sa$$
  done
  wikilink=`echo ${artistname} | sed -e "s/ /_/g"`
  echo "# ${artistname}" > /tmp/au$$
  echo "" >> /tmp/au$$
  echo "[Wikipedia entry](https://en.wikipedia.org/wiki/${wikilink})" >> /tmp/au$$
  cat /tmp/au$$ /tmp/sa$$ > ${album}.md
  rm -f /tmp/au$$ /tmp/sa$$
  cd ..
done

cd "${TOP}"
for artist in *
do
  [ "${artist}" == "*" ] && continue
  [ -d "${artist}" ] || continue
  [ "${mkartists}" ] && {
    album="${artist}"
    grep "title:" ${artist}/${artist}.md > /dev/null && album="${artist}_index"
    [ -f "${artist}/${album}.md" ] && {
      for disc in ${artist}/*.md
      do
        [ "${disc}" == "${artist}/*.md" ] && continue
        [ "${disc}" == "${artist}/${album}.md" ] && continue
        grep "artist:" ${disc} > /dev/null && {
          artistname=`grep "artist:" ${disc} | head -1 | \
            awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
          break
        }
      done
      [ "${artistname}" ] && {
        if [ ${numcols} -gt 4 ]
        then
          printf "| [${artistname}](Vinyl/${artist}/${album}.md) |\n" >> ../${OUT}
          numcols=1
        else
          printf "| [${artistname}](Vinyl/${artist}/${album}.md) " >> ../${OUT}
          numcols=$((numcols+1))
        fi
      }
    }
  }
done

[ "${mkartists}" ] && {
  while [ ${numcols} -lt 4 ]
  do
    printf "| " >> ../${OUT}
    numcols=$((numcols+1))
  done
  printf "|\n" >> ../${OUT}
}

```

</Details>

## CD_library

My CDs are catalogued in [Collectorz](https://cloud.collectorz.com). To export a Collectorz library:

- Login to Collectorz
- Click the upper left corner dropdown menu
- Click `Export to CSV/TXT`
- On the `Export to CSV / TXT` page select the `CSV` tab
- In the `Settings` section
    - Select `Field Delimiter` to `Comma`
    - Select `Field Enclosure` to `Double Quote`
    - Select `Options` to `Include Field Names as First Row`
    - Leave the `Filename` as `export_albums`
- In the `Columns` section
    - Click on `Manage`
    - Select `My List View columns` and click on `Edit`
    - Select the columns you wish to manage in your CD library and click `Save`

For my scripts to work without much modification you will need to have selected the same columns as I did and sort them in the same order. These are:

```text
  1: Cat No
  2: Artist
  3: Title
  4: Tracks
  5: Release Date
  6: Discs
  7: Box Set
  8: Length
  9: Genre
 10: Label
 11: Format
 12: Original Release Year
 13: Songwriter
 14: Producer
 15: Musician
```

When done selecting columns click the `Generate file` button at the bottom.

The following scripts generate Markdown format files for each of the CDs in the downloaded CSV format Collectorz export and create various indexes of the generated Obsidian vault. Click the arrow to the left of the details link to expand or collapse each script.

<Details markdown="block">

Script to generate Markdown format files for each of the CDs in the downloaded CSV format Collectorz export. You will need to modify this script, changing `data/export_albums.csv` to the location of your downloaded Collectorz CSV export.

### [Tools/CD/mkcd](Tools/CD/mkcd.md) (click to collapse/expand)

```shell

#!/bin/bash
#
# Columns:
# 1: Cat No
# 2: Artist
# 3: Title
# 4: Tracks
# 5: Release Date
# 6: Discs
# 7: Box Set
# 8: Length
# 9: Genre
#10: Label
#11: Format
#12: Original Release Year
#13: Songwriter
#14: Producer
#15: Musician

CDS="../../CD"
update=
numknown=1
[ "$1" == "-u" ] && update=1

[ -d ${CDS} ] || mkdir ${CDS}
[ -d ../../assets/cdcovers ] || mkdir -p ../../assets/cdcovers

cat data/export_albums.csv | while read line
do
  if [ "${first}" ]
  then
    title=`echo ${line} | csvcut -c 3`
    catalog=`echo ${line} | csvcut -c 1 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
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
    [ "${filename}" ] || {
      if [ "${catalog}" ]
      then
        filename="Unknown-${catalog}"
      else
        filename="Unknown-${numknown}"
        $((numknown + 1))
      fi
    }
    echo "Processing ${filename}"
    artist=`echo ${line} | csvcut -c 2`
    artistdir=`echo ${artist} | \
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

    [ -f ${CDS}/${artistdir}/${filename}.md ] && continue

    # Download album cover art
    image=`echo ${filename} | sed -e "s/_Disc_[0-9]//" -e "s/_(Disc_[0-9])//"`
    [ -f "../../assets/cdcovers/${artistdir}-${image}.png" ] || {
      echo "Downloading cover art for ${artist} - ${title}"
      sacad "${artist}" "${title}" 600 \
        ../../assets/cdcovers/${artistdir}-${image}.png 2> /dev/null
    }
    [ -d ${CDS}/${artistdir} ] || mkdir ${CDS}/${artistdir}
    tracks=`echo ${line} | csvcut -c 4 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    discs=`echo ${line} | csvcut -c 6 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    boxset=`echo ${line} | csvcut -c 7 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    length=`echo ${line} | csvcut -c 8 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    genre=`echo ${line} | csvcut -c 9 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    label=`echo ${line} | csvcut -c 10 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    format=`echo ${line} | csvcut -c 11 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    released=`echo ${line} | csvcut -c 12 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    songwriter=`echo ${line} | csvcut -c 13 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    producer=`echo ${line} | csvcut -c 14 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    musician=`echo ${line} | csvcut -c 15 | \
      sed -e "s/^\"//" -e "s/\"$//" -e "s/\"\"/\"/g"`
    echo "---" > ${CDS}/${artistdir}/${filename}.md
    echo "catalog: ${catalog}" >> ${CDS}/${artistdir}/${filename}.md
    echo "title: ${title}" >> ${CDS}/${artistdir}/${filename}.md
    echo "artist: ${artist}" >> ${CDS}/${artistdir}/${filename}.md
    echo "label: ${label}" >> ${CDS}/${artistdir}/${filename}.md
    echo "format: ${format}" >> ${CDS}/${artistdir}/${filename}.md
    echo "tracks: ${tracks}" >> ${CDS}/${artistdir}/${filename}.md
    echo "released: ${released}" >> ${CDS}/${artistdir}/${filename}.md
    echo "discs: ${discs}" >> ${CDS}/${artistdir}/${filename}.md
    echo "boxset: ${boxset}" >> ${CDS}/${artistdir}/${filename}.md
    echo "length: ${length}" >> ${CDS}/${artistdir}/${filename}.md
    echo "genre: ${genre}" >> ${CDS}/${artistdir}/${filename}.md
    echo "songwriter: ${songwriter}" >> ${CDS}/${artistdir}/${filename}.md
    echo "producer: ${producer}" >> ${CDS}/${artistdir}/${filename}.md
    echo "musician: ${musician}" >> ${CDS}/${artistdir}/${filename}.md
    echo "---" >> ${CDS}/${artistdir}/${filename}.md
    echo "" >> ${CDS}/${artistdir}/${filename}.md
    echo "# ${title}" >> ${CDS}/${artistdir}/${filename}.md
    echo "" >> ${CDS}/${artistdir}/${filename}.md
    echo "By ${artist}" >> ${CDS}/${artistdir}/${filename}.md
    echo "" >> ${CDS}/${artistdir}/${filename}.md
    if [ -f "../../assets/cdcovers/${artistdir}-${image}.png" ]
    then
      coverurl="../../assets/cdcovers/${artistdir}-${image}.png"
    else
      coverurl=
    fi
    [ "${coverurl}" ] && {
      echo "![](${coverurl})" >> ${CDS}/${artistdir}/${filename}.md
      echo "" >> ${CDS}/${artistdir}/${filename}.md
    }
    echo "## Album Data" >> ${CDS}/${artistdir}/${filename}.md
    echo "" >> ${CDS}/${artistdir}/${filename}.md
    echo "- Catalog #: ${catalog}" >> ${CDS}/${artistdir}/${filename}.md
    echo "- Label: ${label}" >> ${CDS}/${artistdir}/${filename}.md
    echo "- Format: ${format}" >> ${CDS}/${artistdir}/${filename}.md
    echo "- Tracks: ${tracks}" >> ${CDS}/${artistdir}/${filename}.md
    echo "- Released: ${released}" >> ${CDS}/${artistdir}/${filename}.md
    echo "- Discs: ${discs}" >> ${CDS}/${artistdir}/${filename}.md
    echo "- Box Set: ${boxset}" >> ${CDS}/${artistdir}/${filename}.md
    echo "- Length: ${length}" >> ${CDS}/${artistdir}/${filename}.md
    echo "- Genre: ${genre}" >> ${CDS}/${artistdir}/${filename}.md
    echo "- Songwriter: ${songwriter}" >> ${CDS}/${artistdir}/${filename}.md
    echo "- Producer: ${producer}" >> ${CDS}/${artistdir}/${filename}.md
    echo "- Musician: ${musician}" >> ${CDS}/${artistdir}/${filename}.md
    echo "" >> ${CDS}/${artistdir}/${filename}.md
  else
    first=1
  fi
done

```

</Details>

<Details markdown="block">

Generate various indexes into the Markdown format files created in the Obsidian vault with the previous script. This script can generate lists of CDs sorted by artist or title in list or table format.

### [Tools/CD/mkdisc](Tools/CD/mkdisc.md) (click to collapse/expand)

```shell

#!/bin/bash

VAULT="${HOME}/Documents/Obsidian/Obsidian-Media-Vault"
TOP="${VAULT}/CD"

usage() {
  printf "\nUsage: mkdisc [-A] [-T] [-f] [-p /path/to/CD] [-t] [-u]"
  printf "\nWhere:"
  printf "\n\t-A indicates sort by Artist"
  printf "\n\t-T indicates sort by Title (default)"
  printf "\n\t-f indicates overwrite any pre-existing CD index markdown"
  printf "\n\t-p /path/to/CD specifies the full path to the CD folder"
  printf "\n\t(default: ${HOME}/Documents/Obsidian/Obsidian-Media-Vault/CD)"
  printf "\n\t-t indicates create a table rather than listing"
  printf "\n\t-u displays this usage message and exits\n\n"
  exit 1
}

mktable=
overwrite=
sortorder="title"

while getopts "ATfp:tu" flag; do
    case $flag in
        A)
            sortorder="artist"
            ;;
        T)
            sortorder="title"
            ;;
        f)
            overwrite=1
            ;;
        p)
            TOP="${OPTARG}"
            ;;
        t)
            mktable=1
            numcols=1
            ;;
        u)
            usage
            ;;
    esac
done
shift $(( OPTIND - 1 ))

[ -d "${TOP}" ] || {
  echo "$TOP does not exist or is not a directory. Exiting."
  exit 1
}

if [ "${mktable}" ]
then
  if [ "${sortorder}" == "title" ]
  then
    disc_index="Table_of_CD_by_Title"
  else
    disc_index="Table_of_CD_by_Artist"
  fi
else
  if [ "${sortorder}" == "title" ]
  then
    disc_index="CD_by_Title"
  else
    disc_index="CD_by_Artist"
  fi
fi

cd "${TOP}"

[ "${overwrite}" ] && rm -f ${VAULT}/${disc_index}.md

if [ -f ${VAULT}/${disc_index}.md ]
then
  echo "${disc_index}.md already exists. Use '-f' to overwrite an existing index."
  echo "Exiting without changes."
  exit 1
else
  echo "# CD" > ${VAULT}/${disc_index}.md
  echo "" >> ${VAULT}/${disc_index}.md
  if [ "${mktable}" ]
  then
    if [ "${sortorder}" == "title" ]
    then
      echo "## Table of CD by Title" >> ${VAULT}/${disc_index}.md
    else
      echo "## Table of CD by Artist" >> ${VAULT}/${disc_index}.md
    fi
  else
    if [ "${sortorder}" == "title" ]
    then
      echo "## Index of CD by Title" >> ${VAULT}/${disc_index}.md
    else
      echo "## Index of CD by Artist" >> ${VAULT}/${disc_index}.md
    fi
    echo "" >> ${VAULT}/${disc_index}.md
    echo "| **[A](#a)** | **[B](#b)** | **[C](#c)** | **[D](#d)** | **[E](#e)** | **[F](#f)** | **[G](#g)** | **[H](#h)** | **[I](#i)** | **[J](#j)** | **[K](#k)** | **[L](#l)** | **[M](#m)** | **[N](#n)** | **[O](#o)** | **[P](#p)** | **[Q](#q)** | **[R](#r)** | **[S](#s)** | **[T](#t)** | **[U](#u)** | **[V](#v)** | **[W](#w)** | **[X](#x)** | **[Y](#y)** | **[Z](#z)** |" >> ${VAULT}/${disc_index}.md
    echo "|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|" >> ${VAULT}/${disc_index}.md
    echo "" >> ${VAULT}/${disc_index}.md
  fi
  echo "" >> ${VAULT}/${disc_index}.md
  if [ "${mktable}" ]
  then
    if [ "${sortorder}" == "title" ]
    then
      echo "| **Title by Artist** | **Title by Artist** | **Title by Artist** | **Title by Artist** | **Title by Artist** |" >> ${VAULT}/${disc_index}.md
    else
      echo "| **Artist: Title** | **Artist: Title** | **Artist: Title** | **Artist: Title** | **Artist: Title** |" >> ${VAULT}/${disc_index}.md
    fi
    echo "|--|--|--|--|--|" >> ${VAULT}/${disc_index}.md
  else
    heading="0-9"
    artist_heading=
    echo "### ${heading}" >> ${VAULT}/${disc_index}.md
    echo "" >> ${VAULT}/${disc_index}.md
  fi

  if [ "${mktable}" ]
  then
    if [ "${sortorder}" == "title" ]
    then
      ls -1 */*.md | sort -k 2 -t'/' > /tmp/discs$$
      while read disc
      do
        artist=`echo ${disc} | awk -F '/' ' { print $1 } '`
        filename=`echo ${disc} | awk -F '/' ' { print $2 } ' | sed -e "s/\.md//"`
        [ "${artist}" == "${filename}" ] && continue
        artistname=`grep "artist:" ${disc} | head -1 | \
          awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
        [ "${artistname}" ] || {
          echo "${disc} needs an artist: tag. Skipping."
          continue
        }
        title=`grep "title:" ${disc} | awk -F ':' ' { print $2 } ' | \
          sed -e 's/^ *//' -e 's/ *$//' -e "s/^\"//" -e "s/\"$//"`
        [ "${title}" ] || {
          echo "${disc} needs a title: tag. Skipping."
          continue
        }
        if [ ${numcols} -gt 4 ]
        then
          printf "| [${title}](CD/${disc}) by ${artistname} |\n" >> ${VAULT}/${disc_index}.md
          numcols=1
        else
          printf "| [${title}](CD/${disc}) by ${artistname} " >> ${VAULT}/${disc_index}.md
          numcols=$((numcols+1))
        fi
      done < <(cat /tmp/discs$$)

      while [ ${numcols} -lt 5 ]
      do
        printf "| " >> ${VAULT}/${disc_index}.md
        numcols=$((numcols+1))
      done
      printf "|\n" >> ${VAULT}/${disc_index}.md
      rm -f /tmp/discs$$
    else
      for artist in *
      do
        [ "${artist}" == "*" ] && continue
        [ -d "${artist}" ] || continue
        cd "${artist}"
        artistname=
        for disc in *.md
        do
          [ "${disc}" == "*.md" ] && continue
          [ "${disc}" == "${artist}.md" ] && continue
          [ "${artistname}" ] || {
            artistname=`grep "artist:" ${disc} | head -1 | \
              awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
          }
          title=`grep "title:" ${disc} | awk -F ':' ' { print $2 } ' | \
            sed -e 's/^ *//' -e 's/ *$//' -e "s/^\"//" -e "s/\"$//"`
          if [ ${numcols} -gt 4 ]
          then
            printf "| ${artistname}: [${title}](CD/${artist}/${disc}) |\n" >> ${VAULT}/${disc_index}.md
            numcols=1
          else
            printf "| ${artistname}: [${title}](CD/${artist}/${disc}) " >> ${VAULT}/${disc_index}.md
            numcols=$((numcols+1))
          fi
        done
        cd ..
      done

      while [ ${numcols} -lt 5 ]
      do
        printf "| " >> ${VAULT}/${disc_index}.md
        numcols=$((numcols+1))
      done
      printf "|\n" >> ${VAULT}/${disc_index}.md
    fi
  else
    if [ "${sortorder}" == "title" ]
    then
      ls -1 */*.md | sort -k 2 -t'/' > /tmp/discs$$
    else
      ls -1 */*.md | sort -k 1 -t'/' > /tmp/discs$$
    fi
    while read disc
    do
      artist=`echo ${disc} | awk -F '/' ' { print $1 } '`
      filename=`echo ${disc} | awk -F '/' ' { print $2 } ' | sed -e "s/\.md//"`
      [ "${artist}" == "${filename}" ] && continue
      artistname=`grep "artist:" ${disc} | head -1 | \
        awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
      [ "${artistname}" ] || {
        echo "${disc} needs an artist: tag. Skipping."
        continue
      }
      title=`grep "title:" ${disc} | awk -F ':' ' { print $2 } ' | \
        sed -e 's/^ *//' -e 's/ *$//' -e "s/^\"//" -e "s/\"$//"`
      [ "${title}" ] || {
        echo "${disc} needs a title: tag. Skipping."
        continue
      }
      if [ "${sortorder}" == "title" ]
      then
        first=${title:0:1}
      else
        first=${artistname:0:1}
      fi
      if [ "${heading}" == "0-9" ]
      then
        [ "${first}" -eq "${first}" ] 2> /dev/null || {
          [ "${first}" == "#" ] || {
            [ "${first}" == "?" ] || {
              [ "${first}" == "_" ] || {
                heading=${first}
                echo "" >> ${VAULT}/${disc_index}.md
                echo "### ${heading}" >> ${VAULT}/${disc_index}.md
                echo "" >> ${VAULT}/${disc_index}.md
              }
            }
          }
        }
      else
        [ "${first}" == "${heading}" ] || {
          [ "${first}" == "." ] || {
            [ "${first}" == "Æ" ] || {
              heading=${first}
              echo "" >> ${VAULT}/${disc_index}.md
              echo "### ${heading}" >> ${VAULT}/${disc_index}.md
              echo "" >> ${VAULT}/${disc_index}.md
            }
          }
        }
      fi
      if [ "${sortorder}" == "title" ]
      then
        echo "- [${title}](CD/${disc}) by **${artistname}**" >> ${VAULT}/${disc_index}.md
      else
        [ "${artistname}" == "${artist_heading}" ] || {
          artist_heading=${artistname}
          echo "" >> ${VAULT}/${disc_index}.md
          echo "#### ${artist_heading}" >> ${VAULT}/${disc_index}.md
          echo "" >> ${VAULT}/${disc_index}.md
        }
        echo "- [${title}](CD/${disc})" >> ${VAULT}/${disc_index}.md
      fi
    done < <(cat /tmp/discs$$)
    rm -f /tmp/discs$$
  fi
fi

```

</Details>

<Details markdown="block">

Generate markdown for each of the CD artists with a link to their Wikipedia article and links to their CD releases. Also generate a markdown document with a table of all CD artists.

### [Tools/CD/mkartists](Tools/CD/mkartists.md) (click to collapse/expand)

```shell

#!/bin/bash

TOP="${HOME}/Documents/Obsidian/Obsidian-Media-Vault/CD"
OUT="CD_Artists.md"

[ -d "${TOP}" ] || {
  echo "$TOP does not exist or is not a directory. Exiting."
  exit 1
}

cd "${TOP}"

mkartists=
numcols=1
overwrite=
remove=
[ "$1" == "-f" ] && overwrite=1
[ "$1" == "-r" ] && remove=1

[ "${remove}" ] || [ "${overwrite}" ] && rm -f ../${OUT}

[ -f ../${OUT} ] || {
  mkartists=1
  echo "# CD Artists" > ../${OUT}
  echo "" >> ../${OUT}
  echo "## List of CD Artists in Vault" >> ../${OUT}
  echo "" >> ../${OUT}
  echo "| **Artist Name** | **Artist Name** | **Artist Name** | **Artist Name** | **Artist Name** |" >> ../${OUT}
  echo "|--|--|--|--|--|" >> ../${OUT}
}

for artist in *
do
  [ "${artist}" == "*" ] && continue
  [ -d "${artist}" ] || continue
  album="${artist}"
  grep "title:" ${artist}/${artist}.md > /dev/null && album="${artist}_index"
  [ "${remove}" ] && {
    rm -f ${artist}/${album}.md
    continue
  }
  if [ "${overwrite}" ]
  then
    grep "title:" ${artist}/${album}.md > /dev/null && continue
    rm -f ${artist}/${album}.md
  else
    [ -f ${artist}/${album}.md ] && continue
  fi
  cd "${artist}"
  echo "" > /tmp/sa$$
  echo "## CD" >> /tmp/sa$$
  echo "" >> /tmp/sa$$
  artistname=
  for disc in *.md
  do
    [ "${disc}" == "*.md" ] && continue
    [ "${disc}" == "${album}.md" ] && continue
    [ "${artistname}" ] || {
      artistname=`grep "artist:" ${disc} | head -1 | \
        awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
    }
    title=`grep "title:" ${disc} | awk -F ':' ' { print $2 } ' | \
      sed -e 's/^ *//' -e 's/ *$//' -e "s/^\"//" -e "s/\"$//"`
    echo "- [${title}](${disc})" >> /tmp/sa$$
  done
  wikilink=`echo ${artistname} | sed -e "s/ /_/g"`
  echo "# ${artistname}" > /tmp/au$$
  echo "" >> /tmp/au$$
  echo "[Wikipedia entry](https://en.wikipedia.org/wiki/${wikilink})" >> /tmp/au$$
  cat /tmp/au$$ /tmp/sa$$ > ${album}.md
  rm -f /tmp/au$$ /tmp/sa$$
  cd ..
done

cd "${TOP}"
for artist in *
do
  [ "${artist}" == "*" ] && continue
  [ -d "${artist}" ] || continue
  [ "${mkartists}" ] && {
    album="${artist}"
    grep "title:" ${artist}/${artist}.md > /dev/null && album="${artist}_index"
    [ -f "${artist}/${album}.md" ] && {
      for disc in ${artist}/*.md
      do
        [ "${disc}" == "${artist}/*.md" ] && continue
        [ "${disc}" == "${artist}/${album}.md" ] && continue
        grep "artist:" ${disc} > /dev/null && {
          artistname=`grep "artist:" ${disc} | head -1 | \
            awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
          break
        }
      done
      [ "${artistname}" ] && {
        if [ ${numcols} -gt 4 ]
        then
          printf "| [${artistname}](CD/${artist}/${album}.md) |\n" >> ../${OUT}
          numcols=1
        else
          printf "| [${artistname}](CD/${artist}/${album}.md) " >> ../${OUT}
          numcols=$((numcols+1))
        fi
      }
    }
  }
done

[ "${mkartists}" ] && {
  while [ ${numcols} -lt 4 ]
  do
    printf "| " >> ../${OUT}
    numcols=$((numcols+1))
  done
  printf "|\n" >> ../${OUT}
}

```

</Details>

## Apple_Music

The creation and curation of an Apple Music markdown format index is a work in progress. An XML format export of an Apple Music library can be generated in Apple Music by selecting `File -> Library -> Export Library`. The exported XML can be very large for large music libraries. Included in this repository are several scripts used to convert and process the Apple Music XML export into Markdown.

Using this [excellent tutorial at Movable Type](https://www.movable-type.co.uk/scripts/itunes-albumlist.html) I was able to craft an XSLT stylesheet to convert the XML to HTML. The HTML formatted Apple Music library export was than converted to Markdown using `pandoc`. The results, after splitting the large markdown, can be seen at [Apple/Albums_by_Genre/Albums_by_Genre.md](Apple/Albums_by_Genre/Albums_by_Genre.md).

The scripts used to perform this initial pass at an Apple Music markdown index can be found in the `Tools/Apple/` folder. Working with XML is unpleasant and I no longer use Apple Music that frequently so this sub-project is languishing due to lack of motivation or interest. If you would like to contribute please do so.

## Roon_library

To index and categorize a [Roon Audio System](https://roonlabs.com) library, the [RoonCommandLine](https://github.com/doctorfree/RoonCommandLine#readme) package can be used. RoonCommandLine provides command line utilities that can be used to list various aspects of a Roon library. The scripts used to produce the Roon markdown for this repository can be found in `Tools/Roon/`. Example Roon markdown can be viewed at:

- [Roon Albums by Artist](Roon_Albums_by_Artist.md)
- [Roon Albums by Composer](Roon_Albums_by_Composer.md)
- [Roon Albums by Genre](Roon_Albums_by_Genre.md)
- [Roon Tracks by Artist](Roon_Tracks_by_Artist.md)

### Roon_playlists

Playlists from the Roon Audio System were generated using the [RoonCommandLine](https://github.com/doctorfree/RoonCommandLine#readme) command `roon -l playtracks`. Roon playlist markdown can be viewed at:

- [Roon Playlists](Roon_Playlists.md)
- [Roon Playlist Tracks](Roon_Playlist_Tracks.md)

## Updates

Updating the vault with new markdown for albums, cds, books, or other media added to your collections is currently in development. Some automation for this task has been initiated in the `Tools/Vinyl/scripts` folder for updating the Vinyl records markdown and cover art with newly added entries to a Discogs collection. This is largely done by querying the Discogs API. To update the Vinyl markdown and cover art for a newly added Discogs album:

```console
cd Tools/Vinyl/scripts
./get-new-album <discogs_release_id>
```

<Details markdown="block">
See the script `Tools/Vinyl/scripts/get-new-album`:

### [Tools/Vinyl/scripts/get-new-album](Tools/Vinyl/scripts/get-new-album.md) (click to collapse/expand)

```shell

#!/bin/bash
#
# get-new-album
#
# Get info on an album just added to your Discogs collection

# Set to the username of the Discogs collection to query
username="doctorfree"
# Find the Discogs release id for the newly added album and put it here:
releaseid=5589433
# Alternately, the release id can be provided as the first argument to the command
[ "$1" ] && releaseid="$1"

# Optionally set the album name and artist name
# title="Moses Live"
# artist="Moses"

# Path to album cover art folder, relative to current folder
coverfolder="../../../assets/albumcovers"

# URL="https://api.discogs.com/releases"
URL="https://api.discogs.com"
REL="${URL}/releases"
MRL="${URL}/masters"
# Not yet used, these are for custom collection fields
FLD="${URL}/users/${username}/collection/fields"
USR="${URL}/users/${username}/collection/releases"

TOP="${HOME}/Documents/Obsidian/Obsidian-Media-Vault/Vinyl"
AGE="github.com/doctorfree/MusicPlayerPlus"
UAG="--user-agent \"MusicPlayerPlus/3.0\""
token="CtvkGQluyminrZuarkmuFJZjXFEvUFpNDxkjNnVP"

[ -d "${TOP}" ] || {
  echo "$TOP does not exist or is not a directory. Exiting."
  exit 1
}

[ -d json ] || mkdir json
[ -d json/${releaseid} ] || mkdir json/${releaseid}

[ -s "json/${releaseid}/${releaseid}.json" ] || {
  curl --stderr /dev/null \
    -A "${AGE}" "${REL}/${releaseid}" \
    -H "Authorization: Discogs token=${token}" | \
    jq -r '.' > "json/${releaseid}/${releaseid}.json"
}

[ -s "json/${releaseid}/${releaseid}_genres.json" ] || {
  cat "json/${releaseid}/${releaseid}.json" | jq '.genres[]' > \
    "json/${releaseid}/${releaseid}_genres.json"
}
[ -s "json/${releaseid}/${releaseid}_styles.json" ] || {
  cat "json/${releaseid}/${releaseid}.json" | jq '.styles[]' > \
    "json/${releaseid}/${releaseid}_styles.json"
}

[ "${title}" ] || {
  title=`cat "json/${releaseid}/${releaseid}.json" | \
  jq '.title' | sed -e "s/\"//g"`
}
titlename=`echo "${title}" | sed -e "s/ /_/g"`

[ "${artist}" ] || {
  artist=`cat "json/${releaseid}/${releaseid}.json" | \
    jq '.artists_sort' | \
    sed -e 's/ ([[:digit:]]\+)//' -e "s/\"//g"`
}
artistname=`echo "${artist}" | sed -e "s/ /_/g"`
filename="${artistname}-${titlename}"
markdown="${filename}.md"

[ -f "${filename}.png" ] || {
  coverurl=$(cat "json/${releaseid}/${releaseid}.json" | \
    jq -r '.images[0].resource_url')
  suffix=`echo "${coverurl}" | awk -F '/' ' { print $NF } ' | \
                               awk -F '.' ' { print $NF } '`
  wget -q -O "${filename}.${suffix}" "${coverurl}"
  [ "${suffix}" == "png" ] || {
    convert "${filename}.${suffix}" "${filename}.png"
    rm -f "${filename}.${suffix}"
  }
}
[ -s "${filename}.png" ] && {
  [ -d "${coverfolder}" ] && {
    cp "${filename}.png" "${coverfolder}/${filename}.png"
  }
}

label=`cat "json/${releaseid}/${releaseid}.json" | \
  jq '.labels[].name' | sed -e "s/\"//g"`

echo "---" > "${markdown}"
echo "title: ${title}" >> "${markdown}"
echo "artist: ${artist}" >> "${markdown}"
echo "label: ${label}" >> "${markdown}"

formats=`cat "json/${releaseid}/${releaseid}.json" | \
         jq -r '.formats[]' | \
         jq -r '.name' | sed -e "s/\"//g"`
cat "json/${releaseid}/${releaseid}.json" | \
         jq -r '.formats[]' | \
         jq -r '.descriptions[]' > "${releaseid}_formats.txt"

# Insert format data for this album
while read format
do
  [ "${format}" == "null" ] && format=
  [ "${format}" ] || continue
  formats="${formats}, ${format}"
done < <(/bin/cat "${releaseid}_formats.txt")
rm -f ${releaseid}_formats.txt
echo "formats: ${formats}" >> "${markdown}"

# Insert genre/styles data for this album
first=1
genres=
while read genre
do
  genre=`echo "${genre}" | sed -e "s/\"//g"`
  [ "${genre}" == "null" ] && genre=
  [ "${genre}" ] || continue
  if [ "${first}" ]
  then
    genres="${genre}"
    first=
  else
    genres="${genres}, ${genre}"
  fi
done < <(/bin/cat "json/${releaseid}/${releaseid}_genres.json")

while read style
do
  style=`echo "${style}" | sed -e "s/\"//g"`
  [ "${style}" == "null" ] && style=
  [ "${style}" ] || continue
  genres="${genres}, ${style}"
done < <(/bin/cat "json/${releaseid}/${releaseid}_styles.json")
echo "genres: ${genres}" >> "${markdown}"

rating=`cat "json/${releaseid}/${releaseid}.json" | \
  jq '.community.rating.average'`
echo "rating: ${rating}" >> "${markdown}"

released=`cat "json/${releaseid}/${releaseid}.json" | \
  jq '.released' | sed -e "s/\"//g"`
echo "released: ${released}" >> "${markdown}"

# Get year from master release if there is one, otherwise use year of release
year=
[ -s json/${releaseid}/${releaseid}_master.json ] || {
  masterid=`cat "json/${releaseid}/${releaseid}.json" | \
    jq -r '.master_id' | sed -e "s/\"//g"`
  [ -z ${masterid} ] || {
    curl --stderr /dev/null \
      -A "${AGE}" "${MRL}/${masterid}" \
      -H "Authorization: Discogs token=${token}" | \
      jq '.' > json/${releaseid}/${releaseid}_master.json
  }
}
[ -f "json/${releaseid}/${releaseid}_master.json" ] && {
  year=`cat "json/${releaseid}/${releaseid}_master.json" | \
    jq -r '.year' | sed -e "s/\"//g"`
}
[ "${year}" == "null" ] && year=
[ "${year}" ] || {
  year=`cat "json/${releaseid}/${releaseid}.json" | \
    jq -r '.year' | sed -e "s/\"//g"`
}
echo "year: ${year}" >> "${markdown}"

echo "releaseid: ${releaseid}" >> "${markdown}"

# Retrieve custom collection fields
[ -s "json/custom_fields.json" ] || {
  curl --stderr /dev/null \
    -A "${AGE}" "${FLD}" \
    -H "Authorization: Discogs token=${token}" | \
      jq -r '.' > "json/custom_fields.json"
}

# Retrieve custom field settings for this release
[ -s "json/${releaseid}/${releaseid}_user.json" ] || {
  curl --stderr /dev/null \
    -A "${AGE}" "${USR}/${releaseid}" \
    -H "Authorization: Discogs token=${token}" | \
      jq -r '.' > "json/${releaseid}/${releaseid}_user.json"
}

# TODO: loop through custom fields, get name of field, get value

# These are the custom collection fields for my collection
echo "mediacondition: ${mediacondition}" >> "${markdown}"
echo "sleevecondition: ${sleevecondition}" >> "${markdown}"
echo "speed: ${speed}" >> "${markdown}"
echo "weight: ${weight}" >> "${markdown}"
echo "notes: ${notes}" >> "${markdown}"
echo "---" >> "${markdown}"
echo "" >> "${markdown}"

echo "# ${title}" >> "${markdown}"
echo "" >> "${markdown}"

echo "By ${artist}" >> "${markdown}"
echo "" >> "${markdown}"

[ -f "${filename}.png" ] && {
  echo "![](../../assets/albumcovers/${filename}.png)" >> "${markdown}"
  echo "" >> "${markdown}"
}

echo "## Album Data" >> "${markdown}"
echo "" >> "${markdown}"

uri=`cat "json/${releaseid}/${releaseid}.json" | \
     jq '.uri' | sed -e "s/\"//g" -e "s/,//g"`
echo "[Discogs URL](${uri})" >> "${markdown}"
echo "" >> "${markdown}"

echo "- Label: ${label}" >> "${markdown}"
echo "- Formats: ${formats}" >> "${markdown}"
echo "- Genres: ${genres}" >> "${markdown}"
echo "- Rating: ${rating}" >> "${markdown}"
echo "- Released: ${released}" >> "${markdown}"
echo "- Year: ${year}" >> "${markdown}"
echo "- Release ID: ${releaseid}" >> "${markdown}"
echo "- Media condition: ${mediacondition}" >> "${markdown}"
echo "- Sleeve condition: ${sleevecondition}" >> "${markdown}"
echo "- Speed: ${speed}" >> "${markdown}"
echo "- Weight: ${weight}" >> "${markdown}"
echo "- Notes: ${notes}" >> "${markdown}"
echo "" >> "${markdown}"

[ -s "json/${releaseid}/${releaseid}_tracks.json" ] || {
  curl --stderr /dev/null \
    -A "${AGE}" "${REL}/${releaseid}" \
    -H "Authorization: Discogs token=${token}" | \
    jq -r '.tracklist[] | "\(.position)%\(.title)%\(.duration)"' > \
    "json/${releaseid}/${releaseid}_tracks.json"
}

# Create track list for this album
echo "## Album Tracks" > /tmp/__insert__
echo "" >> /tmp/__insert__
echo "| **Position** | **Title** | **Duration** |" >> /tmp/__insert__
echo "|--------------|-----------|--------------|" >> /tmp/__insert__
cat "json/${releaseid}/${releaseid}_tracks.json" | while read track
do
  [ "${track}" ] || continue
  position=`echo "${track}" | awk -F '%' ' { print $1 } '`
  title=`echo "${track}" | awk -F '%' ' { print $2 } '`
  duration=`echo "${track}" | awk -F '%' ' { print $3 } '`
  echo "| ${position} | **${title}** | ${duration} |" >> /tmp/__insert__
done
echo "" >> /tmp/__insert__
cat ${markdown} /tmp/__insert__ > /tmp/foo$$
cp /tmp/foo$$ ${markdown}
rm -f /tmp/foo$$ /tmp/__insert__ 

[ -s "json/${releaseid}/${releaseid}_extra.json" ] || {
  curl --stderr /dev/null \
    -A "${AGE}" "${REL}/${releaseid}" \
    -H "Authorization: Discogs token=${token}" | \
    jq -r '.extraartists[] | "\(.name)%\(.role)"' > \
    "json/${releaseid}/${releaseid}_extra.json"
}
[ -s "json/${releaseid}/${releaseid}_extra.json" ] && {
  # Insert artist roles list for this album
  echo "## Artist Roles" > /tmp/__insert__
  echo "" >> /tmp/__insert__
  echo "| **Name** | **Role** |" >> /tmp/__insert__
  echo "|----------|----------|" >> /tmp/__insert__
  cat "json/${releaseid}/${releaseid}_extra.json" | while read artistrole
  do
    [ "${artistrole}" ] || continue
    name=`echo "${artistrole}" | awk -F '%' ' { print $1 } '`
    role=`echo "${artistrole}" | awk -F '%' ' { print $2 } '`
    echo "| **${name}** | ${role} |" >> /tmp/__insert__
  done
  echo "" >> /tmp/__insert__
  cat ${markdown} /tmp/__insert__ > /tmp/foo$$
  cp /tmp/foo$$ ${markdown}
  rm -f /tmp/foo$$ /tmp/__insert__
  echo "" >> "${markdown}"
}

[ -d "${TOP}/${artistname}" ] || mkdir -p "${TOP}/${artistname}"
cp "${markdown}" "${TOP}/${artistname}/${markdown}"

```

</Details>

## See_also

- [README](README.md)
- [Media Queries](Media_Queries.md)
- [Obsidian Book Search Plugin](https://github.com/anpigon/obsidian-book-search-plugin)
- [Tutorial: Create a Bookshelf in Obsidian](https://thebuccaneersbounty.wordpress.com/2021/08/21/tutorial-how-to-create-a-bookshelf-in-obsidian/)
    - [Example Obsidian Bookshelf](https://github.com/GentryGibson/ObsidianBookshelf)
- [Add books using Quickadd and Google Books API](https://github.com/Elaws/script_googleBooks_quickAdd)
- [Readwise](https://readwise.io)
    - [Official Readwise Obsidian Plugin](https://github.com/readwiseio/obsidian-readwise)
    - [Readwise to Obsidian export How-To](https://help.readwise.io/article/125-how-does-the-readwise-to-obsidian-export-integration-work)
- [Nicole van der Hoeven videos](https://www.youtube.com/@nicolevdh)
    - [Getting Started with Obsidian](https://youtube.com/playlist?list=PL-1Nqb2waX4Vba6QDVS5rhnSb9pZGTO4b)
    - [Readwise Reader](https://youtu.be/uNH1JDOmGJw)
    - [Readwise Obsidian plugin](https://youtu.be/Rw1L5sxlnuU)
