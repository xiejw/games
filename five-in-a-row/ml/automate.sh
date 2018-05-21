#!/bin/sh

counter=20

while [ $counter -gt 0 ]
do
  echo "++++++ Round ${counter} `date` "

  cd ..
  xcodebuild -project five-in-a-row.xcodeproj   build && \
  /Users/xiejw/Workspace/games/five-in-a-row/build/Release/five-in-a-row && \
  cd ml && \
  rm games.txt && \
  cp  ~/Desktop/games.txt . && \
  docker run --rm -it -v $NOTEBOOK:/notebooks  --entrypoint=""  keras python training.py && \
  cat ~/Desktop/games.txt >> ~/Desktop/games_history.txt  && \
  rm -f ~/Desktop/games.txt

  counter=$(($counter-1))
done
