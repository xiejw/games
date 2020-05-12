#!/bin/sh

export DOCKER_VOLUME=~/docker_volumn
export DOCKER_PORT=6380

docker run --name gomoku_hparams \
		-v ${DOCKER_VOLUME}/gomoku_hparams:/data \
		-p127.0.0.1:${DOCKER_PORT}:6379 \
		-d redis:6.0
