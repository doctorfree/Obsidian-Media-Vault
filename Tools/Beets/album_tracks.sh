#!/bin/bash
#
# Tracks markdown in artist/album/tracks.md looks like:
#
# # Tracks on "[1986] In My Tribe" by 10,000 Maniacs
# 
# ## Tracks
# 
# /u/audio/Music/10,000 Maniacs/[1986] In My Tribe/01 - What’s the Matter Here_.m4a
#       album: In My Tribe
# albumartist: 10,000 Maniacs
#      artist: 10,000 Maniacs
#  catalognum: 60738-2
#      format: ALAC
#       genre: Soft Rock
#       label: Elektra
#      length: 4:51
#       title: What’s the Matter Here?
#       track: 01
#  tracktotal: 12
#        year: 1987

BEETS="../../Beets"
INPUT="../../../Beets"
MDN="Beets_Album_Tracks.md"

echo "# Beets Album Tracks" > ${MDN}
echo "" >> ${MDN}
cat data/nav.md >> ${MDN}
[ -d ${BEETS} ] || mkdir ${BEETS}

for inputdir in ${INPUT}/*
do
  [ "${inputdir}" == "${INPUT}/*" ] && continue
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
  for inputalbumdir in "${inputdir}"/*
  do
    TXT="${inputalbumdir}/tracks.md"
    [ -f "${TXT}" ] || {
      echo "Missing tracks.md for artist/album ${inputalbumdir}. Skipping."
      continue
    }
    albumdir=`basename "${inputalbumdir}"`
    albumdir=`echo ${albumdir} | \
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
    [ -d "${BEETS}/${artistdir}/${albumdir}" ] || {
      mkdir -p "${BEETS}/${artistdir}/${albumdir}"
    }
    first=1
    cat "${TXT}" | while read line
    do
      end=
      marker=
      echo ${line} | grep "^/u/audio/Music/" > /dev/null && marker=1
      if [ "${marker}" ]
      then
        type="track"
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
              albumartist=`echo ${line} | \
                awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
              ;;
            artist)
              artist=`echo ${line} | \
                awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
              ;;
            genre)
              genre=`echo ${line} | \
                awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
              ;;
            catalognum)
              catalognum=`echo ${line} | \
                awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
              ;;
            format)
              format=`echo ${line} | \
                awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
              ;;
            label)
              label=`echo ${line} | \
                awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
              ;;
            length)
              length=`echo ${line} | \
                awk '{for(i=2;i<=NF;i++){ printf("%s",( (i>2) ? OFS : "" ) $i) } ;}'`
              ;;
            title)
              title=`echo ${line} | \
                awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
              ;;
            track)
              track=`echo ${line} | \
                awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
              ;;
            tracktotal)
              tracktotal=`echo ${line} | \
                awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
              ;;
            year)
              year=`echo ${line} | \
                awk -F ':' ' { print $2 } ' | sed -e 's/^ *//' -e 's/ *$//'`
              ;;
            *)
              continue
              ;;
          esac
        fi
      fi
      if [ "${type}" == "track" ] || [ "${type}" == "end" ]
      then
        [ "${albumartist}" ] && {
          [ "${first}" ] && {
            echo "- [${album}](Beets/${artistdir}/${albumdir}/${filename}.md)" >> ${MDN}
            echo "---" > "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "catalognum: ${catalognum}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "album: ${album}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "albumartist: ${albumartist}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "label: ${label}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "tracktotal: ${tracktotal}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "year: ${year}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "---" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "# Album tracks" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "- **Album:** ${album}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "- **Albumartist:** ${albumartist}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "- **Catalog #:** ${catalognum}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            echo "- **Label:** ${label}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
            first=
          }
          echo "" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
          echo "## Track ${track} - ${title}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
          echo "" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
          echo "- **Artist:** ${artist}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
          echo "- **Format:** ${format}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
          echo "- **Genre:** ${genre}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
          echo "- **Length:** ${length}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
          echo "- **Title:** ${title}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
          echo "- **Track:** ${track}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
          echo "- **Total Tracks:** ${tracktotal}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
          echo "- **Year:** ${year}" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
          echo "" >> "${BEETS}/${artistdir}/${albumdir}/${filename}.md"
        }
      else
        continue
      fi
    done
  done
done
