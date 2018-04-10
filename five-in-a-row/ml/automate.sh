#!/bin/sh

counter=10

while [ $counter -gt 0 ]
do
  echo "++++++ Round ${counter} `date` "

  cd ..
  xcodebuild -project five-in-a-row.xcodeproj   build
  /Users/xiejw/Workspace/games/five-in-a-row/build/Release/five-in-a-row
  cd ml
  tail -n 200000 ~/Desktop/games.txt > ~/Desktop/games_200k.txt
  python training.py

  counter=$(($counter-1))
done
