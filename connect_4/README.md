Connect Four
------------

According to Wikipedia:

> Connect Four is a two-player connection game in which the players first choose a
color and then take turns dropping one colored disc from the top into a
seven-column, six-row vertically suspended grid. The pieces fall straight down,
occupying the lowest available space within the column. The objective of the
game is to be the first to form a horizontal, vertical, or diagonal line of four
of one's own discs.

![ConnectFour](./data/images/Connect_Four.gif)

Let's Play
----------

Simply run the docker:

    make run_docker

How to Train
------------

Libraries
========

    # `expect` is for `unbuffer`
    brew install mysql expect

    # On some Debian, mycli is the replacement for mysql
    apt install mysql-client python3-pip
    apt install mycli

    pip3 install mysql-connector-python keras==2.3.1 tensorflow==1.14


Bootstrap
=========

    # create docker
    . data/sql/create_sql_docker.sh

    # create table
    . data/sql/create_table.sh

    # Generate random data to start with.
    #
    # This will delete old checkpoints!!!!
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
    # Not needed for `launch_self_plays`
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
