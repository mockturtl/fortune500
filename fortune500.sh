#!/bin/bash

TARGET=html;
TAG1="<td class=\"cnncol3\">";
TAG2="<td class=\"cnncol4\">";
REVENUE=revenue.txt 
PROFIT=profit.txt

#fetch html from the web
function download {
  echo 'Cleaning old files...'
  rm -r $TARGET

  local WROOT=http://money.cnn.com/magazines/fortune/fortune500/2011/full_list/
  
  mkdir $TARGET
  echo 'Downloading...'
  wget -nv -i sourcefiles -B $WROOT
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
  echo 'Exporting revenues to file...'
  rm $REVENUE
  grep "${TAG1}" $TARGET/1_100.html >> $REVENUE
  grep "${TAG1}" $TARGET/101_200.html >> $REVENUE
  grep "${TAG1}" $TARGET/201_300.html >> $REVENUE
  grep "${TAG1}" $TARGET/301_400.html >> $REVENUE
  grep "${TAG1}" $TARGET/401_500.html >> $REVENUE

  echo 'Exporting profits to file...'
  rm $PROFIT
  grep "${TAG2}" $TARGET/1_100.html >> $PROFIT
  grep "${TAG2}" $TARGET/101_200.html >> $PROFIT
  grep "${TAG2}" $TARGET/201_300.html >> $PROFIT
  grep "${TAG2}" $TARGET/301_400.html >> $PROFIT
  grep "${TAG2}" $TARGET/401_500.html >> $PROFIT
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
function sumall {
  echo 'Calculating sums.'
  ./sum.py
}

download
parse
extract
format
sumall
