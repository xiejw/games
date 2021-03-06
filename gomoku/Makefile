BUILD=.build
WEIGHT_FILE=data/golden_weights/2021-03-12.h5

default: run

################################################################################
# Plays the game.
################################################################################
run:
	PYTHONPATH=lib python3 cmd/play_with_human.py

################################################################################
# Self plays and training.
################################################################################
train:
	PYTHONPATH=lib python3 cmd/train.py

launch_self_plays:
	PYTHONPATH=lib python3 cmd/launch_self_plays.py

self_plays:
	PYTHONPATH=lib python3 cmd/self_plays.py

bootstrap: clean
	mkdir ${BUILD}
	PYTHONPATH=lib python3 cmd/bootstrap.py
	make train

evaluate:
	PYTHONPATH=lib unbuffer python3 cmd/evaluate.py | tee /tmp/evaluate.txt

elo_rating:
	PYTHONPATH=lib python3 cmd/elo_rating.py

loop:
	. cmd/loop.sh

clean:
	rm -rf ${BUILD}

################################################################################
# Docker related
################################################################################
build_docker:
	docker build -t xiejw/gomoku  \
		--build-arg WEIGHT_FILE=${WEIGHT_FILE} \
		-f docker/Dockerfile \
		.

build_docker_no_cache:
	docker build -t xiejw/gomoku  \
		--no-cache \
		--build-arg WEIGHT_FILE=${WEIGHT_FILE} \
		-f docker/Dockerfile \
		.

run_docker:
	docker run --rm -ti xiejw/gomoku

################################################################################
# Database related
################################################################################
view_db:
	. lib/data/sql/view_table.sh

db:
	. lib/data/sql/connect_table.sh

