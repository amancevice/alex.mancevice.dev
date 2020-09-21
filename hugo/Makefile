public: config.toml $(shell find . -type d -depth 1 -not -name 'public' -not -name 'resources' | xargs find)
	hugo

.PHONY: clean sync

clean:
	rm -rf public

sync: | public
	aws s3 sync $| s3://alexander.mancevice.dev/ --delete
