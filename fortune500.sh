#!/bin/bash

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

#fetch webpages
function download {
  
  checkSources
  
  echo 'Cleaning old files...'
  rm -r $TARGET

  local WROOT=http://money.cnn.com/magazines/fortune/fortune500/2011/full_list/
  
  mkdir $TARGET
  echo 'Downloading...'
  wget -nv -i ${SOURCEFILES} -B $WROOT
  mv index.html 1_100.html  #rename first page for consistency
  mv *.html $TARGET
}

#remove ignored whitespace
function parse {  
  echo 'Parsing html...'
  ./parse.py
}

#copy relevant HTML tags to data files, one per line
function extract {

  checkSources
    
  echo 'Exporting revenues to file...'
  rm $REVENUE
  cat $SOURCEFILES | while read LINE; do
    if [ $LINE = 'index.html' ]; then
      grep "${TAG1}" $TARGET/1_100.html >> $REVENUE
    else
      grep "${TAG1}" $TARGET/$LINE >> $REVENUE
    fi
  done

  echo 'Exporting profits to file...'
  rm $PROFIT
  cat $SOURCEFILES | while read LINE; do
    if [ $LINE = 'index.html' ]; then
      grep "${TAG2}" $TARGET/1_100.html >> $PROFIT
    else
      grep "${TAG2}" $TARGET/$LINE >> $PROFIT
    fi
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

ARGC=$#
i=1
while [ $i -le $ARGC ]; do
  #echo "Argv[$i] = ${!i}"
  if [ ${!i} = '-d' ]; then
    download
  fi      
   i=$((i+1))
done

parse
extract
format
sumAll
