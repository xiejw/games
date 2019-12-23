default: run

run:
	PYTHONPATH=. python3 cmd/play_with_human.py

train:
	PYTHONPATH=. python3 cmd/train.py

view_db:
	. data/sql/view_table.sh

db:
	. data/sql/connect_table.sh

bootstrap:
	mkdir .build

clean:
	rm -rf .build
