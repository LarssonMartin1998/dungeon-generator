.PHONY: run test

run:
	@lua main.lua

test:
	@busted spec/
