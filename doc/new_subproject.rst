How to add new subprojet to Altai in fixnum steps
=================================================

Create project in gerrit
------------------------

http://khar.ci-cd.altai-dev.griddynamics.net/gerrit/#/admin/projects/

If you don't have permissions, ask Alessio Ababilov or
Ivan Melnikov to do that for you.

Remember to ask gerrit to create empty initial commit.


Create branch for current trunk in gerrit
-----------------------------------------

Again, ask Alessio or Ivan if you don't have permissions.


Create project on github
------------------------

Ask Alessio Ababilov to do that for you.


Initialize altai repo locally
-----------------------------

Clone the repo and go into it::

    $ git clone ssh://<gerrit-username>@khar.ci-cd.altai-dev.griddynamics.net:29418/altai
    $ cd altai



Add submodule to Altai project
------------------------------

::
    $ git submodule add ../<repo> repos/altai/<repo>



Start new feature
-----------------

::
    $ hoy-feature <feature_name> [<trunk>]


Work
----

You may add code now or later in separate feature, and make changes
to other sub-projects.


Upload the feature for review
-----------------------------

As with any other feature, you should commit all your changes and call
`hoy-upload`::

    $ git commit -a
    $ hoy-upload

Look at workflow document for details.

