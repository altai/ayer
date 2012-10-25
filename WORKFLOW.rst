Hoy Workflow
============

Initialize a repository
-----------------------

Clone the repo and setup it.

::

    $ G_USERNAME=<you Gerrit username>
    $ git clone ssh://$G_USERNAME@osc-build.vm.griddynamics.net:29418/altai.git
    $ cd altai
    $ cat > .ayer <<EOF
    YUM_REPO_BASEURL_DEV=http://osc-build.vm.griddynamics.net/altai
    JENKINS_BASEURL=http://osc-build.vm.griddynamics.net:8080
    USER=$G_USERNAME
    BRANCH=v1.0.2_trunk
    EOF

Start a feature
---------------

Trunk argument is optional.

::

    $ hoy-feature my-feature v1.0.2_trunk

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
