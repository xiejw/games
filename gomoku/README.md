Gomoku
======

Let's Play
----------

Simply run the docker:

    make run_docker


Bootstrap
---------

Creates the DB docker and SQL table.

```
./lib/data/sql/create_sql_docker.sh
./lib/data/sql/create_table.sh
```

VirtualEnv
----------

Python version upgrade might conflict with pip package version. For example,
near July 2020, Python 3.8 conflicts with tensorflow 1.14. To resolve this,
using a virtual env with specific python version is recommended.

```
# compile python and install to $HOME/opt
wget https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz
tar xzvf
cd Python
./configure --prefix=$HOME/opt/python
make

# install virtualenv in global.
pip3 install virtualenv
cd ~/Workspace
virtualenv penv --python=$HOME/opt/python/bin/python3
source penv/bin/activate
which python3
which pip3

# install dependencies.
pip3 mysql-connector-python keras==2.3.1 tensorflow==1.14
```

