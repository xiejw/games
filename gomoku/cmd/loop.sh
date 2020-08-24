#!/bin/bash

# Log files are
#
# - /tmp/self_plays_main.log (Dumped by launch_self_plays)
# - /tmp/training.log

# Stage 1
# NUM_ITERATIONS=10
# Stage 2
# NUM_ITERATIONS=10
# Stage 3
# NUM_ITERATIONS=10
# Stage 4
# NUM_ITERATIONS=10
# Stage 5
# NUM_ITERATIONS=10
# Stage 6 (just before stage 6, 5 layer to 10).
NUM_ITERATIONS=10

i="0"

while [ $i -lt $NUM_ITERATIONS ]
do

  unbuffer make launch_self_plays
  unbuffer make train | tee -a /tmp/training.log | tee /tmp/training_"$i".log

  i=$[$i+1]
done
