#!/bin/sh

echo "========================================================================="
echo "current time " `date`

mysql --user dummy --host 127.0.0.1 --port 3301 -pdummy_passwd gomoku -e \
  "select * from records ORDER BY id DESC LIMIT 10;"
