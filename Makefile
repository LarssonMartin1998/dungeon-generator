.PHONY: run tests

run:
	@clear && lua main.lua

tests:
	@busted tests/
