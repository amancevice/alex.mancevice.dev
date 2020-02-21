STAGES    := build plan
TERRAFORM := latest
CLEANS    := $(foreach STAGE,$(STAGES),clean@$(STAGE))
IMAGES    := $(foreach STAGE,$(STAGES),image@$(STAGE))
SHELLS    := $(foreach STAGE,$(STAGES),shell@$(STAGE))
BUILD     := $(shell git describe --tags --always)
TIMESTAMP := $(shell date +%s)

CLOUDFRONT_DISTRIBUTION_ID := $$(terraform output cloudfront_distribution_id)
S3_BUCKET                  := $$(terraform output bucket_name)

.PHONY: default clean clobber sync up

default: alexander.sha256sum

.docker:
	mkdir -p $@

.docker/$(BUILD)-plan: .docker/$(BUILD)-build
.docker/$(BUILD)-%:  | .docker
	docker build \
	--build-arg AWS_ACCESS_KEY_ID \
	--build-arg AWS_DEFAULT_REGION \
	--build-arg AWS_SECRET_ACCESS_KEY \
	--build-arg TERRAFORM=$(TERRAFORM) \
	--build-arg TF_VAR_release=$(BUILD) \
	--iidfile $@@$(TIMESTAMP) \
	--tag mancevice.dev:$(BUILD)-$* \
	--target $* \
	.
	cp $@@$(TIMESTAMP) $@

apply: .docker/$(build)@plan .env
	docker run --rm --env-file .env $(shell cat $<)

clean:
	-find .docker -name '' -not -name '*@*' | xargs rm
	-rm -rf alexander.sha256sum

clobber:
	-awk {print} .docker/* 2> /dev/null | xargs docker image rm --force
	-rm -rf .docker

sync:
	aws s3 sync alexander s3://$(S3_BUCKET)/
	aws cloudfront create-invalidation --distribution-id $(CLOUDFRONT_DISTRIBUTION_ID) --paths '/*'

up:
	open http://localhost:8000/
	ruby -run -e httpd alexander -p 8000

alexander.sha256sum: alexander
	sha256sum alexander/* | sha256sum > alexander.sha256sum

$(IMAGES): image@%: .docker/$(BUILD)-%

$(SHELLS): shell@%: .docker/$(BUILD)-%
	docker run --rm -it --entrypoint sh --env-file .env $(shell cat $<)
