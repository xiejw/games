#!/bin/sh

counter=20

while [ $counter -gt 0 ]
do
  echo "++++++ Round ${counter} `date` "

  cd ..
  xcodebuild -project five-in-a-row.xcodeproj   build && \
  RL_TIMES_IN_SECS=2400.0 /Users/xiejw/Workspace/games/five-in-a-row/build/Release/five-in-a-row && \
  cd ml && \
  cat ~/Desktop/games.txt >> ~/Desktop/games_history.txt  && \
  rm -f games.txt && \
  mv -f ~/Desktop/games.txt . && \
  docker run --rm -it -v /Users/xiejw/Workspace/games/five-in-a-row/ml:/notebooks  --entrypoint=""  keras python training.py

  counter=$(($counter-1))
done
