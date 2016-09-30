#!/bin/bash -e
#
# Install the source data for CRAFT-GP for testing from command line
#
function VEP_GRCh37_84_core_cache() {
    echo "Installing VEP_GRCh37_84_core_cache"
    mkdir -p $1/source_data/ensembl/{cache,plugins}
    cd $1/source_data/ensembl/cache/
    wget ftp://ftp.ensembl.org/pub/release-84/variation/VEP/homo_sapiens_vep_84_GRCh37.tar.gz
    tar -zxvf homo_sapiens_vep_84_GRCh37.tar.gz
    cd -
}
function CADD_plugin_data() {
    echo "Installing CADD_plugin_data"
    mkdir -p $1/source_data/ensembl/plugins/CADD
    cd $1/source_data/ensembl/plugins/CADD/
    wget http://krishna.gs.washington.edu/download/CADD/v1.3/1000G.tsv.gz
    wget http://krishna.gs.washington.edu/download/CADD/v1.3/1000G.tsv.gz.tbi
    cd -
}
function Roadmap_Epigenomics_15_state_model() {
    echo "Installing Roadmap_Epigenomics_15_state_model"
    mkdir -p $1/source_data/roadmap_r9/15_state_model/{raw,bed}
    mkdir -p $1/source_data/roadmap_r9/meta_data/
    if [ ! -e $1/source_data/roadmap_r9/meta_data/roadmap_consolidated_epigenome_ids.csv ] ; then
	cp $CRAFT_GP_DATA/roadmap_r9/meta_data/roadmap_consolidated_epigenome_ids.csv $1/source_data/roadmap_r9/meta_data/
    fi
    # Get files
    cd $1/source_data/roadmap_r9/15_state_model/raw/
    wget http://egg2.wustl.edu/roadmap/data/byFileType/chromhmmSegmentations/ChmmModels/coreMarks/jointModel/final/all.dense.browserFiles.tgz
    tar -zxvf all.dense.browserFiles.tgz
    cd -
    # files are renamed and tabix indexed for use with VEP
    python $CRAFT_GP_SCRIPTS/process_roadmap.py --state 15 --meta $1/source_data/roadmap_r9/meta_data/roadmap_consolidated_epigenome_ids.csv --rename EDACC
}
function HapMap_recombination_map() {
    echo "Installing HapMap_recombination_map"
    # This should be included with CRAFT source
    if [ ! -d "$1/source_data/genetic_map_HapMapII_GRCh37" ] ; then
	mkdir -p $1/source_data/genetic_map_HapMapII_GRCh37/
	cd $1/source_data/genetic_map_HapMapII_GRCh37/
	wget ftp://ftp.ncbi.nlm.nih.gov/hapmap/recombination/2011-01_phaseII_B37/genetic_map_HapMapII_GRCh37.tar.gz
	tar -zxvf genetic_map_HapMapII_GRCh37.tar.gz
	cd -
    fi
}
function UCSC_cytogenetic_bands() {
    echo "Installing UCSC_cytogenetic_bands"
    # This should be included with CRAFT source
    if [ ! -f "$1/source_data/ucsc/cytoBand.txt" ] ; then
	mkdir -p $1/source_data/ucsc/
	cd $1/source_data/ucsc/
	wget http://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/cytoBand.txt.gz
	gunzip cytoBand.txt.gz
	cd -
    fi
}
##########################################################
# Main script starts here
##########################################################
# Fetch top-level installation directory from command line
TOP_DIR=$1
if [ -z "$TOP_DIR" ] ; then
    echo Usage: $(basename $0) DIR
    exit
fi
if [ -z "$(echo $TOP_DIR | grep ^/)" ] ; then
    TOP_DIR=$(pwd)/$TOP_DIR
fi
if [ ! -d "$TOP_DIR" ] ; then
    mkdir -p $TOP_DIR
fi
VEP_GRCh37_84_core_cache $TOP_DIR
CADD_plugin_data $TOP_DIR
Roadmap_Epigenomics_15_state_model $TOP_DIR
HapMap_recombination_map $TOP_DIR
UCSC_cytogenetic_bands $TOP_DIR
##
#
