Libraries
========

    # `expect` is for unbuffer
    brew install mysql expect

    # On some Debian, mycli is the replacement for mysql
    apt install mysql-client python3-pip
    apt install mycli

    pip3 install mysql-connector-python keras=2.3.1 tensorflow==1.14


Bootstrap
=========

    # create docker
    . data/sql/create_sql_docker.sh

    # create table
    . data/sql/create_table.sh

    # Generate random data to start with.
    #
    # This will delete old data!!!!
    make bootstrap

One-Off
=======

    make run
    make self_plays
    make train

Loop
====

    . loop.sh


Some Useful Cmds
================

    # Remove logs containing `raise`.
    grep -nRH raise /tmp/*.log | awk 'BEGIN { FS = ":" } ; {system("rm " $1)}'

    # Check liveness of self_plays
    ps aux | grep python | grep self_plays | wc

    # Kills all self_plays
    ps aux | grep self_plays | grep python | awk '{system("kill -9 " $2)}'

    # Keeps checking number of self_plays.
    while true; do
      sleep 180;
      date;
      ps aux | grep python | grep self_plays | wc;
    done

Databases
=========

    select count(*) from records;
    delete from records;
