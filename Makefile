name   := mancevice.dev
stages := build plan
build  := $(shell git describe --tags --always)
shells := $(foreach stage,$(stages),shell@$(stage))

terraform_version := 0.12.6

.PHONY: all clean up alexander.sha256sum

all: alexander.sha256sum

.docker:
	mkdir -p $@

.docker/$(build)@plan: .docker/$(build)@build
.docker/$(build)@%: | .docker
	docker build \
	--build-arg AWS_ACCESS_KEY_ID \
	--build-arg AWS_DEFAULT_REGION \
	--build-arg AWS_SECRET_ACCESS_KEY \
	--build-arg TERRAFORM_VERSION=$(terraform_version) \
	--build-arg TF_VAR_release=$(build) \
	--iidfile $@ \
	--tag $(name):$(build)-$* \
	--target $* .

apply: .docker/$(build)@plan
	docker run --rm \
	--env AWS_ACCESS_KEY_ID \
	--env AWS_DEFAULT_REGION \
	--env AWS_SECRET_ACCESS_KEY \
	$(shell cat $<)

clean:
	-docker image rm -f $(shell awk {print} .docker/*)
	-rm -rf .docker alexander.sha256sum

up:
	open http://localhost:8000/
	ruby -r un -e httpd alexander -p 8000

alexander.sha256sum:
	sha256sum alexander/* | sha256sum > alexander.sha256sum

$(stages): %: .docker/$(build)@%

$(shells): shell@%: .docker/$(build)@%
	docker run --rm -it \
	--entrypoint /bin/sh \
	--env-file .env \
	$(shell cat $<)
