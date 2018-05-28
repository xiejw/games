#!/bin/sh

counter=0
total=20
# About 20 epochs samples,
totalLines=350000

function compile {
  cd ..
  xcodebuild -project five-in-a-row.xcodeproj   build
  cd ml
}

function train {
  docker run --rm -it -v /Users/xiejw/Workspace/games/five-in-a-row/ml:/notebooks  --entrypoint=""  keras python training.py
}

function prepare_data {
  cat ~/Desktop/games.txt >> ~/Desktop/games_history.txt  && \
  rm -f games.txt && \
  tail -n $totalLines ~/Desktop/games_history.txt > games.txt && \
  /bin/cp distribution.h5 distribution-`date +%s`.h5 && \
  /bin/cp -f distribution.h5 distribution-last.h5
}

function rollback {
  echo "rollback"
  /bin/cp -f distribution-last.h5 distribution.h5
  /bin/cp -f DistributionLastIteration.mlmodel Distribution.mlmodel
  /bin/rm -f `ls distribution-15*.h5 | sort | tail -n 1`
  compile
}

while [ $counter -lt $total ]
do
  echo "++++++ Round ${counter} `date` "

  compile
  if [ $counter -gt 0 ]; then
    RATING_TIME_IN_SECS=900.0 /Users/xiejw/Workspace/games/five-in-a-row/build/Release/five-in-a-row
    if [ "$?" = "123" ]; then
      rollback
    fi
  fi
  RL_TIME_IN_SECS=2400.0 /Users/xiejw/Workspace/games/five-in-a-row/build/Release/five-in-a-row && \
    prepare_data && \
    train

  counter=$(($counter+1))
done
