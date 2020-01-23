default: run

run:
	PYTHONPATH=. python3 cmd/play_with_human.py

train:
	PYTHONPATH=. python3 cmd/train.py

launch_self_plays:
	PYTHONPATH=. python3 cmd/launch_self_plays.py

self_plays:
	PYTHONPATH=. python3 cmd/self_plays.py

view_db:
	. data/sql/view_table.sh

db:
	. data/sql/connect_table.sh

bootstrap: clean
	mkdir .build
	PYTHONPATH=. python3 cmd/bootstrap.py
	make train

clean:
	rm -rf .build

# Docker related
#
build_docker:
	docker build -t xiejw/connect_4 \
		--build-arg WEIGHT_FILE=golden_weights/2020-01-22.h5 \
		-f docker/Dockerfile \
		.

run_docker:
	docker run --rm -ti xiejw/connect_4
