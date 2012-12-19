Configuration Files
===================

The `ayer-*` scripts use configuration files from ~/.config/ayer directory.

The `hoy-*` scripts use configuration file .ayer that lies at the same
level as .git directory of the base git project.

Hoy - Developer Tools
=====================

hoy-status
----------

Show Gerrit username, root git repository, current trunk, feature, and
changed files of changes in all git repositories.


hoy-sync [-r|--rebase]
----------------------

Fetch all branches from Gerrit repositories.

Options:
* --rebase - rebase all submodules after fetching.


hoy-feature [-f|--force] [-d|-D|--delete] feature [branch]
----------------------------------------------------------

Prepares environment for working at requested `feature` for
requested trunk `branch` and sets commit hooks if needed.
This command checks out all git repos to `feature` branch. If
`feature` does not exist, it is created. If `feature` already exists,
repository will be checked out to it; if `branch` is given, than
`feature` will be retargeted for this `branch`.

Options:
* --force - recreate feature even if it exists;
* --delete - drop feature instead of creating.


hoy-upload [-p|--pretend] [-f|--force] [-i|--ignore]
----------------------------------------------------

`hoy-upload` sends all new commits of the current feature to review.

Options:
* --pretend - do not send, just print what would be sent;
* --force - send all patches even if some pushs failed (it's possible
if you have pulled commits of another developer: Gerrit will reject
them because it already has them);
* --ignore - resend all patches even if they seem to be already sent.


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


ayer-accept build_commit
------------------------

Accept `build_commit` of the base git project to its target branch as
far as corresponding commits in submodules. All changed RPMs are
rebuilt.

The script fails if some commits are not submittable (i.e. have
correct reviews in Gerrit) or fast-forward is impossible. All problems
are reported.


ayer-is-acceptable build_commit
-------------------------------

Check if `build_commit` is acceptable its target branch. Does not
build anything.


ayer-build-topic build_commit user
----------------------------------

Build a feature from `build_commit` in the base git project. The result
is placed to `$user/$branch/$topic` directory on the build server,
where `branch` and `topic` correspond to `build_commit`.

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
