#!/bin/bash

# This script opens 4 terminal windows.

i="0"

while [ $i -lt 20 ]
do

  j="0"
  while [ $j -lt 69 ]
  do
    (unbuffer make self_plays 2>&1 | tee -a /tmp/self_plays_"$j".log) &
    j=$[$j+1]
  done

  unbuffer make self_plays | tee -a /tmp/self_plays.log

  unbuffer make train | tee -a /tmp/training.log | tee /tmp/training_"$i".log

  i=$[$i+1]
done
