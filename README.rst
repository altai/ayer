Introduction
============

Ayer is a system that aims to help managing git repositories of a
single project and build RPMs from sources in a safe and fast manner.

Ayer consists of scripts in two groups:
* ayer - scripts for build robots and maintainer;
* hoy - scripts for developer.

Ayer uses git submodules to put together git repositories for
different subprojects. The root project will be referred as "the base
git project". 

Synonims
========

* feature = topic

Configuration Files
===================

The ayer group uses configuration files from ~/.config/ayer directory.

The hoy group use sconfiguration file .ayer that lies at the same
level as .git directory of the base git project.

Hoy - Developer Tools
=====================

hoy-sync
--------

hoy-sync initializes submodules, fetches all branches from Gerrit
repositories, and sets commit hook if needed.


hoy-feature feature [branch]
-----------

hoy-feature prepares environment for working at requested `feature` for
requested trunk `branch`. This command checks out all git repos to
`feature` branch. If `feature` does not exist, it is created.

hoy-build [-f]
--------------

hoy-build sends all new commits of the current to review and asks for
building of the feature. Optional `-f` argument forces build even if
some commits failed to send (it's possible if you have pulled commits
of another developer: Gerrit will reject them because it already
has them).

hoy-changelog [base_treeish]
----------------------------

Prints a sample changelog relative to `base_treeish` (default: the trunk).


Ayer - Maintainer Tools
=======================

ayer-create-trunk base_version trunk_name
-----------------------------------------

Creates a new trunk starting from base version. `trunk_name` is
suffixed with `_trunk` if required. All trunk branches are created and
the trunk RPMs are rebuilt from scratch.

ayer-build-trunk trunk_name
---------------------------

Rebuilds the trunk RPMs from scratch.


ayer-delete-trunk trunk_name
---------------------------

Dangerous!

Delete the trunk branches and RPMs.


ayer-accept build_commit build_branch
-------------------------------------

Accept `build_commit` of the base git repository to `build_branch` as
far as corresponding commits in submodules. All changed RPMs are
rebuilt.

The script fails if some commits are not submittable (i.e. have
correct reviews in Gerrit) or fast-forward is impossible. All problems
are reported.

ayer-is-acceptable  build_commit build_branch
---------------------------------------------

Check if `build_commit` is acceptable to `build_branch`. Does not
build anything.

ayer-build-topic -c commit -u user -b branch -t topic
-----------------------------------------------------

Build a feature from `commit` in the base git repository. The result
is placed to `$user/$branch/$topic` directory on the build server.

Reports all acceptability problems as just a warning.

ayer-rpm [-bs|-ba]
------------------

Build an RPM from current git repository. Accepts the same `-bs` or `-ba`
as `rpmbuild` command.

ayer-mock [mock_dir] [root_dir]
-------------------------------

Builds binary RPMs from source RPMs in `$root_dir/SRPMS` directory in
safe and fast mock environment.

`mock_dir` defaults to `ayer` and `root_dir` to `$PWD`.
