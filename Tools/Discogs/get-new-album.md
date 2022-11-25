# get-new-album

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

# URL="https://api.discogs.com/releases"
URL="https://api.discogs.com"
REL="${URL}/releases"
MRL="${URL}/masters"
# Not yet used, these are for custom collection fields
FLD="${URL}/users/${username}/collection/fields"
USR="${URL}/users/${username}/collection/releases"

HERE=`pwd`
TOP="${HERE}/Discogs"
AGE="github.com/doctorfree/MusicPlayerPlus"
UAG="--user-agent \"MusicPlayerPlus/3.0\""
coverfolder="${HERE}/assets/albumcovers"
token="CtvkGQluyminrZuarkmuFJZjXFEvUFpNDxkjNnVP"

[ -d "${TOP}" ] || mkdir -p "${TOP}"
[ -d "${coverfolder}" ] || {
  [ -d "${HERE}/assets" ] || mkdir -p "${HERE}/assets"
  mkdir -p "${coverfolder}"
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
  cat "json/${releaseid}/${releaseid}.json" | jq -r '.genres[]' > \
    "json/${releaseid}/${releaseid}_genres.json"
}
[ -s "json/${releaseid}/${releaseid}_styles.json" ] || {
  cat "json/${releaseid}/${releaseid}.json" | jq -r '.styles[]' > \
    "json/${releaseid}/${releaseid}_styles.json"
}

[ "${title}" ] || {
  title=`cat "json/${releaseid}/${releaseid}.json" | jq -r '.title'`
}
titlename=`echo ${title} | \
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

[ "${artist}" ] || {
  artist=`cat "json/${releaseid}/${releaseid}.json" | \
    jq -r '.artists[0].name' | sed -e 's/ ([[:digit:]]\+)//'`
}
artistname=`echo ${artist} | \
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
    mv "${filename}.png" "${coverfolder}/${filename}.png"
  }
}

label=`cat "json/${releaseid}/${releaseid}.json" | jq -r '.labels[].name'`

echo "---" > "${markdown}"
echo "title: ${title}" >> "${markdown}"
echo "artist: ${artist}" >> "${markdown}"
echo "label: ${label}" >> "${markdown}"

formats=`cat "json/${releaseid}/${releaseid}.json" | \
         jq -r '.formats[]' | jq -r '.name'`
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

rating=`cat "json/${releaseid}/${releaseid}.json" | jq '.community.rating.average'`
echo "rating: ${rating}" >> "${markdown}"

released=`cat "json/${releaseid}/${releaseid}.json" | jq -r '.released'`
echo "released: ${released}" >> "${markdown}"

# Get year from master release if there is one, otherwise use year of release
year=
[ -s json/${releaseid}/${releaseid}_master.json ] || {
  masterid=`cat "json/${releaseid}/${releaseid}.json" | jq -r '.master_id'`
  [ -z ${masterid} ] || {
    curl --stderr /dev/null \
      -A "${AGE}" "${MRL}/${masterid}" \
      -H "Authorization: Discogs token=${token}" | \
      jq '.' > json/${releaseid}/${releaseid}_master.json
  }
}
[ -f "json/${releaseid}/${releaseid}_master.json" ] && {
  year=`cat "json/${releaseid}/${releaseid}_master.json" | jq -r '.year'`
}
[ "${year}" == "null" ] && year=
[ "${year}" ] || {
  year=`cat "json/${releaseid}/${releaseid}.json" | jq -r '.year'`
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

[ -f "${coverfolder}/${filename}.png" ] && {
  echo "![](../../assets/albumcovers/${filename}.png)" >> "${markdown}"
  echo "" >> "${markdown}"
}

echo "## Album Data" >> "${markdown}"
echo "" >> "${markdown}"

uri=`cat "json/${releaseid}/${releaseid}.json" | jq -r '.uri'`
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
rm -f "${markdown}"
```
