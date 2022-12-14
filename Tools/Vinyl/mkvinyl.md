# mkvinyl

```shell
#!/bin/bash
#
# mkvinyl
#
# Generate various indexes into the Markdown format files created in the
# Obsidian vault with the previous script. This script can generate lists
# of records sorted by artist or title in list or table format.

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
