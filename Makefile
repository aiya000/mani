all: style test

install:
	gem install rubocop

style:
	rubocop lib

test:
	ruby spec.rb

.PHONY: test
