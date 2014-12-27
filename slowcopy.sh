#!/bin/bash

# slowcopy.sh
#
# Copies files to a folder in chunks.
# Can be useful for autoloading torrent dirs, when you are adding a lot of torrents
# Does not traverse into subfolders

APPVERSION=1.0

trap "reset; echo Slowcopy $APPVERSION terminated; exit" SIGINT SIGTERM

if [ -z "$1" ]; then
  echo -e "Syntax: slowcopy.sh <sourcedir> <targetdir> <files per batch> <waittime>"
  exit
fi

function init()
{
  # Terminal colors
  DEF="\x1b[0m"
  WHITE="\e[0;37m"
  LIGHTBLACK="\x1b[30;01m"
  BLACK="\x1b[30;11m"
  LIGHTBLUE="\x1b[34;01m"
  BLUE="\x1b[34;11m"
  LIGHTCYAN="\x1b[36;01m"
  CYAN="\x1b[36;11m"
  LIGHTGRAY="\x1b[37;01m"
  GRAY="\x1b[37;11m"
  LIGHTGREEN="\x1b[32;01m"
  GREEN="\x1b[32;11m"
  LIGHTPURPLE="\x1b[35;01m"
  PURPLE="\x1b[35;11m"
  LIGHTRED="\x1b[31;01m"
  RED="\x1b[31;11m"
  LIGHTYELLOW="\x1b[33;01m"
  YELLOW="\x1b[33;11m"

  SAVEIFS=$IFS
  IFS=$(echo -e -en "\n\b")


}

function precalc()
{
  echo -e Calculating how many items to process...

  ITEMSTOTAL=0
  for i in $( find $DIR -maxdepth 1 -type f ); do
    ITEMSTOTAL=$(( ITEMSTOTAL + 1 ))
  done

  if [[ "$CHUNKS" -ge "$ITEMSTOTAL" ]]; then
    #echo -e "Fewer files than chunk ($CHUNKS, $ITEMSTOTAL)"
    BATCHTOTAL=1
  else
    #echo -e "More files than chunk ($CHUNKS, $ITEMSTOTAL)"
    BATCHTOTAL=$(($ITEMSTOTAL / $CHUNKS))
    if (( $ITEMSTOTAL % $CHUNKS )); then
      #echo -e REST
      #echo -e "BT: $BATCHTOTAL"
      #echo -e "MOD: $(( $ITEMSTOTAL % $CHUNKS ))"
      BATCHTOTAL=$(($BATCHTOTAL + 1))
    fi
  fi
  clear
  echo -e ""$CYAN"## Slowcopy"$DEF""
  echo -e
  echo -e ""$CYAN"Settings:"$DEF""
  echo -e ""$GRAY"Sourcedir:                   "$YELLOW"$DIR"$DEF""
  echo -e ""$GRAY"Targetdir:                   "$YELLOW"$T_DIR"$DEF""
  echo -e ""$GRAY"Files per batch:             "$YELLOW"$CHUNKS"$DEF""
  echo -e ""$GRAY"Waittime inbetween batches:  "$YELLOW"$WAITTIME"$DEF""
  echo -e
  echo -e ""$CYAN"Estimates for this Slowcopy session:"$DEF""
  echo -e ""$GRAY"Number of files to copy:     "$YELLOW"$ITEMSTOTAL"$DEF""
  echo -e ""$GRAY"Number of batches:           "$YELLOW"$BATCHTOTAL"$DEF""
  echo -e
  echo -e
  echo -e ""$CYAN"Launching in 5 seconds..."$DEF""
  sleep 5
}

function bheader()
{
  clear
  echo -e ""$CYAN"## Slowcopy > Batch $BATCHNO/$BATCHTOTAL"$DEF""
  echo -e ""$CYAN"## Processing $CHUNKS items... ($ITEMSREMAINING items remaining)"$DEF""
  echo -e
}

function scprocess()
{
  ITEMSREMAINING=$ITEMSTOTAL

  ITEMNO=1
  BATCHNO=1
  COUNTDOWN=$CHUNKS

  bheader
  for i in $( find $DIR -maxdepth 1 -type f ); do

    echo -e ""$GRAY"Item $ITEMNO/$ITEMSTOTAL: "$YELLOW"$(basename $i)"$DEF""
    cp "$i" $T_DIR
    ITEMNO=$(( ITEMNO + 1 ))
    COUNTDOWN=$(( COUNTDOWN - 1 ))
    ITEMSREMAINING=$(( ITEMSREMAINING -1))

    if [[ "$COUNTDOWN" -le "0" ]]; then
      echo -e
      echo -e ""$CYAN"## Batch complete, waiting $WAITTIME seconds..."$DEF""
      sleep $WAITTIME
      COUNTDOWN=$CHUNKS
      BATCHNO=$(( BATCHNO + 1 ))
      bheader
    fi
  done
  IFS=$SAVEIFS
}

DIR=$1
T_DIR=$2
CHUNKS=$3
WAITTIME=$4

#main
init
precalc
scprocess
reset
echo -e "$ITEMSTOTAL items processed!"
echo -e "Slowcopy finished."

exit
