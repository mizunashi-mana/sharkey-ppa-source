#!/usr/bin/env make -f

.PHONY: all
all: build

.PHONY: build
build: pkg
	scripts/build-deb '$<'

pkg: files templates scripts envs
	scripts/create-pkg-files '$@'
