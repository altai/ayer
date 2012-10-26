Developers Workflow
===================

Signup on Gerrit
----------------
Visit the project's gerrit server and follow Register procedure.
Setup username and public key for use in ssh-based git protocol.

Note: different projects can have different associated Gerrit servers.


Initialize a project
--------------------

Clone the repo and setup it. We recommend to specify a trunk branch at
the beginning, however, it can be set later.

::

    $ git clone ssh://<gerrit-username>@osc-build.vm.griddynamics.net:29418/altai.git -b v1.0.2_trunk
    $ cd altai


Start a feature
---------------

Run `hoy-feature`. You may omit trunk argument if you want to stay on
current trunk.

Note. If you are not on a feature or trunk branch (e.g., you stay on
`master` branch), you _must_ specify the trunk.

::

    $ hoy-feature my-feature [v1.0.2_trunk]


Determining current status
--------------------------

Get current trunk and feature name and list of changes in all git repositories:

::

    $ hoy-status


Building the feature
--------------------

Commit your changes starting from submodules. The last commit is in the
base git repository (i.e., `altai`).

::

    $ cd repos/altai/focus
    $ git commit
    $ cd -
    $ git commit


Ask for a build.

::

    $ hoy-build

If Gerrit doesn't accept all commits, you may force build anyway:

::

    $ hoy-build -f


Rebase to reflect trunk changes
-------------------------------

Rebase starting from submodules.

::

    $ hoy-sync
    $ cd repos/altai/focus
    $ git rebase origin/trunk
    $ cd -


The base git repository usually has problems in rebase.

::

    $ git rebase origin/trunk
    $ git add .
    $ git rebase --continue
    $ hoy-build
