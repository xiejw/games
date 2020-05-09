#!/bin/sh

export DOCKER_VOLUME=~/docker_volumn
export DOCKER_PORT=3301

docker run --name gomoku_db \
		-e MYSQL_ROOT_PASSWORD=root_passwd \
		-e MYSQL_DATABASE=gomoku \
		-e MYSQL_USER=dummy \
		-e MYSQL_PASSWORD=dummy_passwd \
		-v ${DOCKER_VOLUME}/gomoku:/var/lib/mysql \
		-p127.0.0.1:${DOCKER_PORT}:3306 \
		-d mariadb:10.4
