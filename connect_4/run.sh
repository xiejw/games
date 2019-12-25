#!/bin/bash

# This script opens 4 terminal windows.

i="0"

while [ $i -lt 20 ]
do

  j="0"
  while [ $j -lt 69 ]
  do
    make self_plays &
    j=$[$j+1]
  done

  make self_plays

  make train

  i=$[$i+1]
done
