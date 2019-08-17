.PHONY: all clean up

all: alexander.sha256sum

clean:
	-rm -rf .docker alexander.sha256sum

up:
	ruby -r un -e httpd alexander -p 8000

alexander.sha256sum:
	sha256sum alexander/* | sha256sum > alexander.sha256sum
