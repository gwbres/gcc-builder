PWD = $(shell pwd)

################
# environment
################
# PREFIX: 
#  installation path prefix
PREFIX ?= $(PWD)

# SUPPORTED_LANGUAGES:
#  list of languages to support by compiler
GCC_LANGUAGES ?= \
	c,c++,fortran,go,objc,obj-c++

# GCC_VERSION: 
#  version of the compiler to build & install
GCC_VERSION = 11.1.0

# threads support
GCC_THREADS ?= posix

################
# required tools
################
GIT ?= /usr/bin/git
GIT_CLONE = $(GIT) clone
GIT_CHECKOUT = $(GIT) checkout

WGET ?= /usr/bin/wget

################
# constants
################
GNU_URL = https://ftp.gnu.org/gnu
GCC_GIT_URL = gcc.gnu.org/git/gcc.git
GCC_DIR = gcc
GCC_TAG = releases/gcc-$(GCC_VERSION)
GCC_BUILD_DIR = build
GCC_CONFIG = $(GCC_DIR)/config.log
GCC_BUILD = $(GCC_BUILD_DIR)/test
GCC_INSTALL = $(PREFIX)/gcc

GCC_PREREQUISITES = \
	$(GCC_DIR)/gmp \
	$(GCC_DIR)/mpfr \
	$(GCC_DIR)/mpc \
	$(GCC_DIR)/isl

##################
# variables
##################
GCC_CONF_OPTS = \
	--enable-shared \
	--enable-threads=$(GCC_THREADS) \
	--enable-__cxa_atexit \
	--enable-languages=$(GCC_LANGUAGES) \
	--prefix=$(PREFIX)

ifeq ($(GCC_DISABLE_MULTILIB),y)
GCC_CONF_OPTS += --disable-multilib
endif
ifeq ($(GCC_ENABLE_MULTILIB),y)
GCC_CONF_OPTS += --enable-multilib
endif

all: $(GCC_INSTALL)

# clone gcc sources
$(GCC_DIR):
	$(GIT_CLONE) git://$(GCC_GIT_URL) $@

# creates build subdir
$(GCC_BUILD_DIR): $(GCC_DIR) 
	mkdir -p $@

# checkout desired tag 
# force prerequisites download, in case we're building a new revision
checkout: $(GCC_BUILD_DIR)
	cd $(GCC_DIR) && $(GIT_CHECKOUT) $(GCC_TAG)
	rm -rf $(GCC_PREREQUISITES) 
	rm -f $(GCC_CONFIG)

# download GCC prerequisites
$(GCC_PREREQUISITES): checkout 
	cd $(GCC_DIR) && ./contrib/download_prerequisites

# configure GCC
$(GCC_CONFIG): $(GCC_PREREQUISITES)
	cd $(GCC_DIR) && ./configure $(GCC_CONF_OPTS)

$(GCC_BUILD): $(GCC_CONFIG)
	make -C $(GCC_DIR) -j8

$(GCC_INSTALL): $(GCC_BUILD)
	sudo make -C $(GCC_DIR) install

show-versions: $(GCC_DIR)
	cd $(GCC_DIR) && $(GIT) tag -l

.PHONY: clean
clean:
	rm -f $(GCC_CONFIG)
	make -C $(GCC_DIR) clean

.PHONY: distclean
distclean:
	make -C $(GCC_DIR) distclean
