Developers Workflow
===================

Signup on Gerrit
----------------
Visit the project's gerrit server and follow Register procedure.
Setup username and public key for use in ssh-based git protocol.

Note: different projects can have different associated Gerrit servers.


Initialize a project
--------------------

Clone the repo and go into it::

    $ git clone ssh://<gerrit-username>@khar.ci-cd.altai-dev.griddynamics.net:29418/altai
    $ cd altai


Start a feature
---------------

Run `hoy-feature`. You may omit trunk argument if you stay on a
feature and want to use its trunk::

    $ hoy-feature my-feature [v1.1_trunk]


If you already have a feature for trunk `A` and want to retarget it for
trunk `B` instead (e.g., if trunk `A` was closed and `B` is the new trunk
now), you can retarget the feature::

    $ hoy-feature my-feature B


Determining current status
--------------------------

Get current trunk and feature name and list of changes in all git
repositories::

    $ hoy-status


Uploading the feature for review
--------------------------------

Commit your changes starting from submodules. Commit in the root git
repository (i.e., `altai`) must be the last. `hoy-changelog` command
will write `ChangeLog` for you automatically.

::

    $ cd repos/altai/focus
    $ git commit .
    $ cd -
    $ hoy-changelog
    $ git commit .


Send for review::

    $ hoy-upload

If Gerrit doesn't accept all commits, you may force uploading::

    $ hoy-upload -f


Rebase to reflect trunk changes
-------------------------------

Make sure that you have no uncommited changes::

    $ hoy-status


Rebase submodules automatically::

    $ hoy-sync -r


If some submodules failed to rebase, visit them and finish rebasing manually.

The base git repository must be always rebased manually.

::

    $ git rebase origin/<you trunk here>
    $ git add .
    $ git rebase --continue
