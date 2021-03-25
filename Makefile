SHELL := /bin/bash

base:
	docker build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) -t panda_melodic_latest -t panda_melodic_latest -f Dockerfile . 

