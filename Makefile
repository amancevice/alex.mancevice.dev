all: build

build:
	cd hugo && hugo

sync: build
	aws s3 sync hugo/public s3://mancevice-dev-us-west-2-alexander --dryrun

up:
	cd hugo && hugo serve

.PHONY: all build sync up
