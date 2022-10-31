GCC builder
===========

GCC builder is a `Makefile` to compile and manually install a desired
revision of the GCC compiler.

The script let the user control which languages are to be supported,
which thread API is to be used, etc..

Tested with

* gcc 8.1.0
* gcc 9.1.0
* gcc 11.1.0 (default)

Builder is a makefile

## Getting started

Install requirements

```shell
apt-get install git tar build-essentials
```

Default build (current default gcc is 11.1.0):

```shell
make
```

## Custom build

Custom revision

```shell
make GCC_VERSION=12.1.0
```

Custom languages

```shell
# disable fortran, go..
make GCC_SUPPORTED_LANGUAGES=c,c++
```

## Useful commands

Show existing revisions

```shell
make show-versions
```

For a given revision, the `releases/gcc-` prefix should be omitted
