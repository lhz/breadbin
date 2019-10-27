
default: test

tools: bin/bgdetect

bin/bgdetect: src/tools/bgdetect.cr
	crystal build -o $@ $^

test:
	crystal spec -- --no-color
