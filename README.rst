#CRAFT-GP-galaxy
===============

Development of Galaxy tools to wrap the CRAFT ("Credible Refinement and
Annotation of Functional Targets") pipeline:
https://github.com/johnbowes/CRAFT-GP

Tools
-----

The main tool which wraps the complete pipeline is:

 * ``craft_gp.xml``

Setup
-----

Get the CRAFT-GP pipeline from GitHub, e.g.::

    cd $HOME
    git clone https://github.com/johnbowes/CRAFT-GP

Set the ``CRAFT_GP_SCRIPTS`` environment variable so the tools
can locate the scripts::

    export CRAFT_GP_SCRIPTS=$HOME/CRAFT-GP/scripts

Dependencies
------------

The ``install_tool_deps.sh`` script can be used to install the
dependencies locally, for example::

    install_tool_deps.sh /path/to/local_tool_dependencies

This can then be targeted in a Galaxy installation by adding the
following lines to the ``dependency_resolvers_conf.xml`` file::

    <galaxy_packages base_path="/path/to/local_tool_dependencies" />
    <galaxy_packages base_path="/path/to/local_tool_dependencies" versionless="true" />

ideally before the ``<conda ... />`` resolvers; see
https://docs.galaxyproject.org/en/latest/admin/dependency_resolvers.html#galaxy-packages-dependency-resolver.

The ``tool_dependencies.xml`` file should handle the installation of the
tool dependencies if installed via a Galaxy toolshed.

Reference data
--------------

Both CRAFT-GP and the Variant Effect Predictor (VEP) need additional
reference data in order to run (see the ``README`` for ``CRAFT-GP``).

The ``install_source_data.sh`` script can be used to fetch and
install these data in an automated manner for the Galaxy tool.

The script requires the following packages to be available:

 * ``CRAFT-GP`` (for the ``CRAFT_GP_SCRIPTS`` and ``CRAFT_GP_DATA``
   environment variables)
 * ``tabix``
 * ``pandas``

By default the script attempts to install into the ``source_data``
directory pointed to by the ``CRAFT-GP`` environment variable, for
example::

    install_source_data.sh

To install to an alternative location, specify it explicitly on the
command line, for example::

    install_source_data.sh /path/to/CRAFT-GP/source_data

Epigenome names and groups
--------------------------

The lists of epigenome names and groups used by the tool are taken from
the ``craft_gp_macros.xml`` file, which in turn is generated from
the ``roadmap_consolidated_epigenome_ids.csv`` file (distributed with
CRAFT-GP) using the ``build_epigenomes_macros.sh`` script, for
example::

    build_epigenomes_macros.sh /path/to/CRAFT-GP/source_data/roadmap_r9/meta_data/roadmap_consolidated_epigenome_ids.csv

(It should only be necessary to rebuild the macros if this file changes
in CRAFT-GP.)

Testing
-------

The ``run_planemo_tests.sh`` script can automatically install the
dependencies (using the ``install_tool_deps.sh`` script) and run the
tool tests using the ``planemo`` package.

The script accepts any arguments recognised by ``planemo test``;
typical usage is::

    ./run_planemo_tests.sh --galaxy_root /PATH/TO/GALAXY/INSTALL

See the planemo documentation for more details:

 * `planemo test command <http://planemo.readthedocs.io/en/latest/commands.html#test-command>`_

Known Issues
------------

 * Currently all R dependencies are essentially bundled into a single
   (unversioned) dependency package, rather than being pinned to specific
   versions of each package. (Source code for the R dependencies can change
   URLs as newer versions are released, breaking the dependency
   installation).
 * VEP version 84 requires access to port 3337 to reach
   ``ensembldb.ensembl.org`` (using the options
   ``--host=130.88.97.228 --port=3337`` when calling VEP). It may be
   necessary to allow access via this port on your local system when
   setting up the Galaxy tools.
 * Installation of the reference data required by CRAFT-GP and VEP is
