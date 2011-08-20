#!/bin/bash

ARGC=$#

TAG1="<td class=\"cnncol3\">"
TAG2="<td class=\"cnncol4\">"

REVENUE=revenue.txt 
PROFIT=profit.txt
SOURCEFILES=sourcefiles
TARGET=html

#verify input file exists
function checkSources {
  if [ ! -f ${SOURCEFILES} ]; then
    echo 'ERROR: No sourcefiles list available'
    exit 1
  fi
}

#verify files downloaded
function checkTargets {
  if [ ! -d $TARGET ]; then
    echo 'ERROR: Target directory /'$TARGET' does not exist; run -d to download'
    exit 2
  fi
}

#delete files
function clean {
  echo 'Cleaning old files...'
  if [ -d $TARGET ]; then
    rm -r $TARGET
  fi
}

#fetch webpages
function download {
  
  checkSources
  
  clean
  
  local WROOT=http://money.cnn.com/magazines/fortune/fortune500/2011/full_list/
  
  mkdir $TARGET
  echo 'Downloading...'
  wget -nv -i ${SOURCEFILES} -B $WROOT
  mv *.html $TARGET
}

#remove ignored whitespace
function parse {  
  
  checkTargets
  
  checkSources
  
#  i=0
#  cat $SOURCEFILES | while read LINE; do
#    #FILES[${i}]=$LINE
#    FILES=$FILES' '$LINE
#    i=$((i+1))
#    echo $FILES
#  done
  
  echo 'Parsing html...'
  ./parse.py $SOURCEFILES $TARGET
}

#copy relevant HTML tags to data files, one per line
function extract {

  checkSources
  
  echo 'Exporting revenues to file...'
  rm $REVENUE
  cat $SOURCEFILES | while read LINE; do
    grep "${TAG1}" $TARGET/$LINE >> $REVENUE
  done

  echo 'Exporting profits to file...'
  rm $PROFIT
  cat $SOURCEFILES | while read LINE; do
    grep "${TAG2}" $TARGET/$LINE >> $PROFIT
  done
}

#remove extraneous text characters from floating-point numbers
function format {
  echo 'Formatting numerical data...'
  sed -i 's/,//' $REVENUE $PROFIT       #strip commas
  sed -i "s/${TAG1}//" $REVENUE         #strip tags
  sed -i "s/${TAG2}//" $PROFIT
  sed -i "s/<\/td>//" $REVENUE $PROFIT
  sed -i "s/N.A./0/" $PROFIT            #strip n/a values
  sed -i "s/[ \t]*//" $REVENUE $PROFIT  #strip whitespace
}

#add the numerical data
function sumAll {
  echo 'Calculating sums.'
  ./sum.py
}

#while getopts d: flag
#  do
#    case $flag in 
#      d)
#        download
#        ;;
#      ?)
#        echo 'Unrecognized option'
#      esac
#  done
#  shift $(( OPTIND - 1 ))

i=1  
while [ $i -le $ARGC ]; do
  #echo "Argv[$i] = ${!i}"
  case ${!i} in 
    '-d') download
          ;;
    '-c') clean
          echo 'Finished.'
          exit 0
          ;;
  esac    
  i=$((i+1))
done

parse
extract
format
sumAll
