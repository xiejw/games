Libraries
========

    brew install mysql
    apt install mysql-client python3-pip
    apt install mycli

    pip3 install mysql-connector-python keras tensorflow==1.14


Bootstrap
=========

    # create docker
    . data/sql/create_sql_docker.sh

    # create table
    . data/sql/create_table.sh

    # generate random data to start with
    m bootstrap


