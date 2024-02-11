#!/usr/bin/env make -f

include env/env.make

ENV_FILES=\
	env/env.make \
	env/params.make

PKG_VERSION_DEB_MAIN=$(subst -,+,$(PKG_VERSION_SHARKEY))

SOURCE_TARBALL=pkg/sharkey_$(PKG_VERSION_DEB_MAIN).orig.tar.gz
PKG_FILES_DIR=pkg/sharkey-$(PKG_VERSION_DEB_MAIN)
DEBIAN_FILES_DIR=$(PKG_FILES_DIR)/debian

.PHONY: all
all: build

.PHONY: build
build: pkg
	./script/build-deb '$(PKG_FILES_DIR)'

pkg: $(SOURCE_TARBALL) $(PKG_FILES_DIR) $(DEBIAN_FILES_DIR)

$(SOURCE_TARBALL): $(ENV_FILES)
	env \
		GIT_COMMIT_REF=$(SHARKEY_SOURCE_GIT_COMMIT_REF) \
		GIT_REPO=$(SHARKEY_SOURCE_GIT_REPO) \
		script/download-src '$@'

$(PKG_FILES_DIR): $(SOURCE_TARBALL)
	rm -rf '$@'
	mkdir -p '$@'
	tar -C '$@' -zxf '$<'

$(DEBIAN_FILES_DIR): src $(PKG_FILES_DIR)
	cp -r '$<' '$@'

VERSION.txt: $(ENV_FILES)
	echo $(PKG_VERSION_DEB_MAIN) > $@
