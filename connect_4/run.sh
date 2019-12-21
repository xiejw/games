#!/bin/bash

# This script opens 4 terminal windows.

i="0"

while [ $i -lt 4000 ]
do
  make run
  make train
done
