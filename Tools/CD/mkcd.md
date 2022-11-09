# mkcd

```shell
#!/bin/bash
#
# mkcd
#
# Generate Markdown format files for each of the CDs in the downloaded CSV
# format Collectorz export. You will need to modify this script, changing
# data/export_albums.csv to the location of your downloaded Collectorz CSV export.
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
