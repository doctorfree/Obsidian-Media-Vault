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

