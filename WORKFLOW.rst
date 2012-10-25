Hoy Workflow
============

Initialize a repository
-----------------------

Clone the repo and sync it.

::

    $ git clone http://osc-build.vm.griddynamics.net:9090/altai
    $ cd altai
    $ hoy-sync


Start a feature
---------------

::

    $ hoy-feature my-feature v1.2.3_trunk

Building the feature
--------------------

Commit yor changes starting from submodules. The last commit is in the
base git repository (i.e., `altai`).

::

    $ cd repos/altai/focus
    $ git commit
    $ cd -
    $ git commit
    
Ask for a build.

::

    $ hoy-build


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
