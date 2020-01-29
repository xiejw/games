BUILD=.build

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
	PYTHONPATH=lib python3 cmd/evaluate.py

loop:
	. cmd/loop.sh

clean:
	rm -rf ${BUILD}

################################################################################
# Docker related
################################################################################
build_docker:
	docker build -t xiejw/connect_4 \
		--build-arg WEIGHT_FILE=data/golden_weights/2020-01-22.h5 \
		-f docker/Dockerfile \
		.

run_docker:
	docker run --rm -ti xiejw/connect_4

################################################################################
# Database related
################################################################################
view_db:
	. lib/data/sql/view_table.sh

db:
	. lib/data/sql/connect_table.sh

