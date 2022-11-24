# mkrecords

```shell
#!/bin/bash
#
# mkrecords
#
# Generate Markdown format files for each of the records in the downloaded CSV
# format Discogs export. You will need to modify this script, changing
# data/doctorfree-collection-discogs.csv to the location of your downloaded
# Discogs CSV export.
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
