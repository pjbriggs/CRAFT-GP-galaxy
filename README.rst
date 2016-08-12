CRAFT-GP-galaxy
===============

Development of Galaxy tools to wrap the CRAFT-GP pipeline:
https://github.com/johnbowes/CRAFT-GP

Tools
-----

The following tools have been created:

 * ``define_regions.xml`` - wraps the ``define_regions_main.rb`` script
 * ``credible_snps.xml`` - wraps the ``filter_summary_stats.py`` and
   ``credible_snps_main.R`` scripts
 * ``annotate_credible_snps.xml`` - wraps the ``annotation.py`` script
 * ``visualise_credible_snps.xml`` - wraps the ``visualisation_main.R``
    script

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

The ``tool_dependencies.xml`` file handles the installation of the
tool dependencies if installed via a Galaxy toolshed.

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

 * Source code for the R dependencies can change URLs as newer versions
   are released, breaking the build.
 * The ``annotate_credible_snps`` tool needs the GRCh38 core cache data
   from Ensembl but for now this needs to be added manually.
