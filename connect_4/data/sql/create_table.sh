#!/bin/sh

mysql --user dummy --host 127.0.0.1 --port 3301 -pdummy_passwd connect_4 < ./data/sql/create_table.sql
