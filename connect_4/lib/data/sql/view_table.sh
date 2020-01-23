#!/bin/sh

mysql --user dummy --host 127.0.0.1 --port 3301 -pdummy_passwd connect_4 -e \
  "select * from records ORDER BY id DESC LIMIT 10;"
