#!/bin/bash

ARGC=$#

TAG1="<td class=\"cnncol3\">"
TAG2="<td class=\"cnncol4\">"

REVENUE=revenue.txt 
PROFIT=profit.txt
SOURCEFILES=sourcefiles
TARGET=html

if [ -z "$YEAR" ]; then
  export YEAR="2012"
fi

#verify input file exists
function checkSources {
  if [ ! -f ${SOURCEFILES} ]; then
    cat<<EOF
ERROR: No sourcefiles list available
EOF
    exit 1
  fi
}

#verify files downloaded
function checkTargets {
  if [ ! -d $TARGET ]; then
    cat<<EOF
ERROR: Target directory '${TARGET}/' does not exist; run with '-d' to download
EOF
    exit 2
  fi
}

#delete files
function clean {
  cat<<EOF
Cleaning old files...
EOF
  if [ -d $TARGET ]; then
    rm -r $TARGET
  fi
}

#fetch webpages
function download {
  
  checkSources
  
  clean
  
  local WROOT="http://money.cnn.com/magazines/fortune/fortune500/${YEAR}/full_list/"
  
  mkdir $TARGET
  cat<<EOF
Downloading data for ${YEAR}...
EOF
  wget -nv -i ${SOURCEFILES} -B $WROOT
  mv *.html $TARGET
}

#remove ignored whitespace
function parse {  
  
  checkTargets
  
  checkSources
  
  cat<<EOF
Parsing html...
EOF
  ./parse.py $SOURCEFILES $TARGET
}

#copy relevant HTML tags to data files, one per line
function extract {

  checkSources
  
  cat<<EOF
Exporting revenues to file...
EOF
  rm $REVENUE
  cat $SOURCEFILES | while read LINE; do
    grep "${TAG1}" $TARGET/$LINE >> $REVENUE
  done

  cat<<EOF
Exporting profits to file...
EOF
  rm $PROFIT
  cat $SOURCEFILES | while read LINE; do
    grep "${TAG2}" $TARGET/$LINE >> $PROFIT
  done
}

#remove extraneous text characters from floating-point numbers
function format {
  cat<<EOF
Formatting numerical data...
EOF
  sed -i 's/,//' $REVENUE $PROFIT       #strip commas
  sed -i "s/${TAG1}//" $REVENUE         #strip tags
  sed -i "s/${TAG2}//" $PROFIT
  sed -i "s/<\/td>//" $REVENUE $PROFIT
  sed -i "s/N.A./0/" $PROFIT            #strip n/a values
  sed -i "s/[ \t]*//" $REVENUE $PROFIT  #strip whitespace
  sed -i '/^\s*$/d' $REVENUE $PROFIT   #strip blank lines
}

#add the numerical data
function sumAll {
  cat<<EOF
Calculating sums with downloaded data.
  Verifying line count in files:
  $(wc -l ${REVENUE})
  $(wc -l ${PROFIT})
EOF
  ./sum.py
}

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
