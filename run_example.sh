#!/bin/bash
#
# Run example CRAFT-GP pipeline based on docs
#
# Set up dependencies
TOOL_DEPENDENCIES_DIR=$(dirname $0)/test.tool_dependencies.craft-gp
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
#
# 1. Define regions
echo "### Running define_regions_main.rb ###"
mkdir -p output/regions/
ruby ${CRAFT_GP_SCRIPTS}/define_regions_main.rb \
     -i $(dirname $0)/test-data/test_index_snps.in \
     -o output/regions \
     -m 0.1
#
# 2. Credible SNPs
echo "### Running filter_summary_stats.py ###"
mkdir -p output/filter/
python ${CRAFT_GP_SCRIPTS}/filter_summary_stats.py \
       --regions $(dirname $0)/test-data/test_region_boundaries.in \
       --stats $(dirname $0)/test-data/test_summary_stats.in \
       --out output/filter/gwas_summary.subset
echo "### Running credible_snps_main.R ###"
mkdir -p output/credible_snps/
Rscript --vanilla ${CRAFT_GP_SCRIPTS}/credible_snps_main.R \
	-r $(dirname $0)/test-data/test_region_boundaries.in \
	-a 1962 \
	-u 8923 \
	-s output/filter/gwas_summary.subset \
        -o output/credible_snps
#
# 3. Annotation
echo "### Running annotation.py ###"
mkdir -p output/annotation/
if [ ! -d "$(basename $CRAFT_GP_DATA)" ] ; then
    ln -s ${CRAFT_GP_DATA}
fi
python ${CRAFT_GP_SCRIPTS}/annotation.py \
       --input output/credible_snps/credible_snp_list_0.99.txt \
       --output output/annotation/annotation
##
#
