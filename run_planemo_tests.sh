#!/bin/bash
#
# Install dependencies and set up environment for
# CRAFT-GP tools, then run tests using planemo
#
# Note that any arguments supplied to the script are
# passed directly to the "planemo test..." invocation
#
# e.g. --install_galaxy (to get planemo to create a
#                        Galaxy instance to run tests)
#
#      --galaxy_root DIR (to run tests using existing
#                         Galaxy instance)
#
# List of dependencies
TOOL_DEPENDENCIES="ruby/1.9
 pyvcf/0.6.8
 pandas/0.16
 R/3.2.1
 dplyr/0.4.3
 coloc/2.3-1
 readr/0.2.2
 tidyr/0.4.1
 stringr/1.0.0
 optparse/1.3.2
 gviz/1.16.1
 biomart/2.28.0
 vep/84
 CRAFT-GP/0.0.0"
# Where to find them
TOOL_DEPENDENCIES_DIR=$(pwd)/test.tool_dependencies.craft-gp
if [ ! -d $TOOL_DEPENDENCIES_DIR ] ; then
    echo WARNING $TOOL_DEPENDENCIES_DIR not found >&2
    echo Creating tool dependencies dir
    mkdir -p $TOOL_DEPENDENCIES_DIR
    echo Installing tool dependencies
    $(dirname $0)/install_tool_deps.sh $TOOL_DEPENDENCIES_DIR
fi
# Load dependencies
for dep in $TOOL_DEPENDENCIES ; do
    env_file=$TOOL_DEPENDENCIES_DIR/$dep/env.sh
    if [ -e $env_file ] ; then
	. $env_file
    else
	echo ERROR no env.sh file found for $dep >&2
	exit 1
    fi
done
# Run the planemo tests
planemo test $@ \
    $(dirname $0)/define_regions.xml \
    $(dirname $0)/credible_snps.xml \
    $(dirname $0)/annotate_credible_snps.xml \
    $(dirname $0)/visualise_credible_snps.xml
##
#
