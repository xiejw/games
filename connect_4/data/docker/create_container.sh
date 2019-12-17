#!/bin/sh

export DOCKER_VOLUME=~/docker_volumn
export DOCKER_PORT=3301

docker run --name connect_4_db \
		-e MYSQL_ROOT_PASSWORD=root_passwd \
		-e MYSQL_DATABASE=connect_4 \
		-e MYSQL_USER=dummy \
		-e MYSQL_PASSWORD=dummy_passwd \
		-v ${DOCKER_VOLUME}/connect_4:/var/lib/mysql \
		-p127.0.0.1:${DOCKER_PORT}:3306 \
		-d mariadb:10.4
