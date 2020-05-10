#!/bin/bash

# Log files are
#
# - /tmp/self_plays_main.log (Dumped by launch_self_plays)
# - /tmp/training.log

NUM_ITERATIONS=20

i="0"

while [ $i -lt $NUM_ITERATIONS ]
do

  unbuffer make launch_self_plays
  unbuffer make view_db | tee -a /tmp/self_plays_main.log
  unbuffer make train | tee -a /tmp/training.log | tee /tmp/training_"$i".log

  i=$[$i+1]
done
