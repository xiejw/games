#!/bin/bash

for file in $(ls distribution-*.h5)
do
  echo $file
  docker run --rm -it -v /Users/xiejw/Workspace/games/five-in-a-row/ml:/notebooks -e WEIGHTS=$file --entrypoint=""  keras python load_weights.py && \
  cd .. && \
  xcodebuild -project five-in-a-row.xcodeproj   build && \
  RATING_TIME_IN_SECS=600.0  POLICY_NAME=$file /Users/xiejw/Workspace/games/five-in-a-row/build/Release/five-in-a-row && \
  cd ml
done
