.PHONY: run test

run:
	@clear && lua main.lua

test:
	@busted spec/
