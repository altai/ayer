Introduction
============

Ayer is a system that aims to help managing git repositories of a
single project and build RPMs from sources in a safe and fast manner.

Ayer consists of console scripts and Gerrit as git repository and code
review tool. There are two groups of console scripts in Ayer:
* `ayer-*` - scripts for build robots and maintainer:
  `accept, build-function, build-topic, build-trunk, create-trunk, delete-trunk, is-acceptable, mock, release, rpm`;
* `hoy-*` - scripts for developer: `build, changelog, feature, sync`.

Ayer uses git submodules to put together git repositories for
different subprojects. The root project will be referred as "the base
git project". 

Synonyms
========

* feature = topic

