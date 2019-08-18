.PHONY: all clean up alexander.sha256sum

all: alexander.sha256sum

clean:
	-rm -rf .docker alexander.sha256sum

up:
	open http://localhost:8000/
	ruby -r un -e httpd alexander -p 8000

alexander.sha256sum:
	sha256sum alexander/* | sha256sum > alexander.sha256sum
