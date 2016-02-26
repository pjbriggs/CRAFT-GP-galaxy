CRAFT-GP-galaxy
===============

Development of Galaxy tools to wrap the CRAFT-GP pipeline:
https://github.com/johnbowes/CRAFT-GP

Tools
-----

The following tools have been created:

 * ``define_regions.xml`` - wraps the ``define_regions_main.rb`` script

Setup
-----

Get the CRAFT-GP pipeline from GitHub, e.g.::

    cd $HOME
    git clone https://github.com/johnbowes/CRAFT-GP

Set the ``CRAFT_GP_SCRIPTS`` environment variable so the tools
can locate the scripts::

    export CRAFT_GP_SCRIPTS=$HOME/CRAFT-GP/scripts
