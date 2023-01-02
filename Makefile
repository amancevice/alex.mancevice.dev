all: build

build up:
	make -C hugo $@

cachebust:
	aws cloudfront create-invalidation --paths '/*' --distribution-id $(shell aws cloudfront list-distributions | jq -r '.DistributionList.Items[]|select(.Comment=="alexander.mancevice.dev").Id')

sync: build
	aws s3 sync hugo/public s3://mancevice-dev-us-west-2-alexander

plan apply: .terraform
	terraform $@

.PHONY: all build cachebust sync up plan apply

.terraform:
	terraform init
	touch $@
