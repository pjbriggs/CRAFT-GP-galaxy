#!/bin/bash
#
# Run example CRAFT-GP pipeline based on docs
#
# Set up dependencies
TOOL_DEPENDENCIES_DIR=$(pwd)/test.tool_dependencies.craft-gp
TOOL_DEPENDENCIES="ruby/1.9
 pandas/0.16
 R/3.2.1
 dplyr/0.4.3
 coloc/2.3-1
 readr/0.2.2
 tidyr/0.4.1
 stringr/1.0.0
 optparse/1.3.2
 pyvcf/0.6.8
 tabix/0.2.6
 vep/84
 CRAFT-GP/0.0.0"
for dep in $TOOL_DEPENDENCIES ; do
    env_file=$TOOL_DEPENDENCIES_DIR/$dep/env.sh
    if [ -e $env_file ] ; then
	. $env_file
    else
	echo ERROR no env.sh file found for $dep >&2
	exit 1
    fi
done
# 0. Set up test data
if [ ! -d test-data ] ; then
    mkdir test-data
fi
#
# 1. Define regions
echo "### Running define_regions_main.rb ###"
ruby ${CRAFT_GP_SCRIPTS}/define_regions_main.rb \
     -i test-data/test_index_snps.in \
     -m 0.1
#
# 2. Credible SNPs
echo "### Running filter_summary_stats.py ###"
python ${CRAFT_GP_SCRIPTS}/filter_summary_stats.py \
       --regions test-data/test_region_boundaries.in \
       --stats test-data/test_summary_stats.in \
       --out gwas_summary.subset
echo "### Running credible_snps_main.R ###"
Rscript --vanilla ${CRAFT_GP_SCRIPTS}/credible_snps_main.R \
	-r test-data/test_region_boundaries.in \
	-a 1962 \
	-u 8923 \
	-s gwas_summary.subset
#
# 3. Annotation
echo "### Running annotation.py ###"
mkdir -p output/annotation
python ${CRAFT_GP_SCRIPTS}/annotation.py \
       --input output/credible_snps/credible_snp_list_0.99.txt \
       --output output/annotation/annotation
##
#
