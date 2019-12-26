Libraries
========

    # expect is for unbuffer
    brew install mysql expect

    #
    apt install mysql-client python3-pip
    apt install mycli

    pip3 install mysql-connector-python keras=2.3.1 tensorflow==1.14


Bootstrap
=========

    # create docker
    . data/sql/create_sql_docker.sh

    # create table
    . data/sql/create_table.sh

    # generate random data to start with
    m bootstrap

Some Useful Cmds
================

    # Remove logs containing `raise`.
    grep -nRH raise /tmp/*.log | awk 'BEGIN { FS = ":" } ; {system("rm " $1)}'

    # Check liveness of self_plays
    ps aux | grep python | grep self_plays | wc

    # Kills all self_plays
    ps aux | grep self_plays | grep python | awk '{system("kill -9 " $2)}'
