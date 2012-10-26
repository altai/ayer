Configuration Files
===================

The `ayer-*` scripts use configuration files from ~/.config/ayer directory.

The `hoy-*` scripts use configuration file .ayer that lies at the same
level as .git directory of the base git project.

Hoy - Developer Tools
=====================

hoy-status
----------

Show Gerrit username, current trunk, feature, and changed files of
changes in all git repositories.


hoy-sync
--------

Initialize submodules and fetch all branches from Gerrit repositories.

hoy-feature feature [branch]
----------------------------

Prepares environment for working at requested `feature` for
requested trunk `branch` and set commit hooks if needed.
This command checks out all git repos to `feature` branch. If
`feature` does not exist, it is created.


hoy-build [-f]
--------------

`hoy-build` sends all new commits of the current feature to review and asks for
building of the feature. Optional `-f` argument forces build even if
some commits failed to send (it's possible if you have pulled commits
of another developer: Gerrit will reject them because it already
has them).

hoy-changelog [base_treeish]
----------------------------

Prints a draft changelog relative to `base_treeish` (default: the trunk).


Ayer - Maintainer Tools
=======================

ayer-create-trunk base_version trunk_name
-----------------------------------------

Create a new trunk starting from `base_version`. `trunk_name` is
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

Accept `build_commit` of the base git project to `build_branch` as
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

Build a feature from `commit` in the base git project. The result
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
