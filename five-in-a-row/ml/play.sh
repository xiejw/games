#!/bin/sh

cd ..
xcodebuild -project five-in-a-row.xcodeproj   build
script -q /dev/null /Users/xiejw/Workspace/games/five-in-a-row/build/Release/five-in-a-row 2>&1 | tee /tmp/play.txt
cd ml

