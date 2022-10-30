all: build

build:
	cd hugo && hugo

cachebust:
	aws cloudfront create-invalidation --paths '/*' --distribution-id $(shell aws cloudfront list-distributions | jq -r '.DistributionList.Items[]|select(.Comment=="alexander.mancevice.dev").Id')

sync: build
	aws s3 sync hugo/public s3://mancevice-dev-us-west-2-alexander

up:
	cd hugo && hugo serve

.PHONY: all build cachebust sync up
