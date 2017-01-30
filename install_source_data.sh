#!/bin/bash -e
#
# Install the source data for CRAFT-GP for testing from command line
#
function _mkdir() {
    # Wrap mkdir -p
    for d in $@ ; do
	if [ ! -d "$d" ] ; then
	    echo "Making directory: $d"
	    mkdir -p $d
	else
	    echo "Directory exists: $d"
	fi
    done
}
function _wget() {
    # Wrap wget -q
    if [ ! -e "$(basename $1)" ] ; then
	echo "Downloading $1"
	local partial=$(basename $1).part
	wget -q $1 -O $partial
	mv $partial $(basename $1)
    else
	echo "$(basename $1): found, not downloading"
    fi
}
function VEP_GRCh37_84_core_cache() {
    echo "*** Installing VEP_GRCh37_84_core_cache ***"
    _mkdir $1/source_data/ensembl/{cache,plugins}
    cd $1/source_data/ensembl/cache/
    _wget ftp://ftp.ensembl.org/pub/release-84/variation/VEP/homo_sapiens_vep_84_GRCh37.tar.gz
    tar -zxf homo_sapiens_vep_84_GRCh37.tar.gz
    cd -
}
function CADD_plugin_data() {
    echo "*** Installing CADD_plugin_data ***"
    _mkdir $1/source_data/ensembl/plugins/CADD
    cd $1/source_data/ensembl/plugins/CADD/
    _wget http://krishna.gs.washington.edu/download/CADD/v1.3/1000G.tsv.gz
    _wget http://krishna.gs.washington.edu/download/CADD/v1.3/1000G.tsv.gz.tbi
    cd -
}
function Roadmap_Epigenomics_15_state_model() {
    echo "*** Installing Roadmap_Epigenomics_15_state_model ***"
    _mkdir $1/source_data/roadmap_r9/15_state_model/{raw,bed}
    _mkdir $1/source_data/roadmap_r9/meta_data/
    cd $1/source_data/roadmap_r9/meta_data/
    _wget https://raw.githubusercontent.com/johnbowes/CRAFT-GP/master/source_data/roadmap_r9/meta_data/roadmap_consolidated_epigenome_ids.csv
    cd -
    # Get files
    cd $1/source_data/roadmap_r9/15_state_model/raw/
    _wget http://egg2.wustl.edu/roadmap/data/byFileType/chromhmmSegmentations/ChmmModels/coreMarks/jointModel/final/all.dense.browserFiles.tgz
    tar -zxvf all.dense.browserFiles.tgz
    cd -
    # files are renamed and tabix indexed for use with VEP
    cd $1
    python $CRAFT_GP_SCRIPTS/process_roadmap.py --state 15 --meta source_data/roadmap_r9/meta_data/roadmap_consolidated_epigenome_ids.csv --rename EDACC
    cd -
}
function HapMap_recombination_map() {
    echo "*** Installing HapMap_recombination_map ***"
    # This should be included with CRAFT source
    _mkdir $1/source_data/genetic_map_HapMapII_GRCh37/
    cd $1/source_data/genetic_map_HapMapII_GRCh37/
    _wget ftp://ftp.ncbi.nlm.nih.gov/hapmap/recombination/2011-01_phaseII_B37/genetic_map_HapMapII_GRCh37.tar.gz
    tar -zxvf genetic_map_HapMapII_GRCh37.tar.gz
    cd -
}
function UCSC_cytogenetic_bands() {
    echo "*** Installing UCSC_cytogenetic_bands ***"
    # This should be included with CRAFT source
    _mkdir $1/source_data/ucsc/
    cd $1/source_data/ucsc/
    _wget http://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/cytoBand.txt.gz
    gunzip -f cytoBand.txt.gz
    cd -
}
##########################################################
# Main script starts here
##########################################################
# Fetch top-level installation directory from command line
TOP_DIR=$(dirname $(cd $CRAFT_GP_DATA && pwd))
if [ ! -z "$1" ] ; then
    TOP_DIR=$1
fi
if [ -z "$TOP_DIR" ] ; then
    echo Usage: $(basename $0) \[DIR\]
    exit
fi
if [ -z "$(echo $TOP_DIR | grep ^/)" ] ; then
    TOP_DIR=$(pwd)/$TOP_DIR
fi
if [ ! -d "$TOP_DIR" ] ; then
    _mkdir $TOP_DIR
fi
if [ -z "$CRAFT_GP_DATA" ] ; then
    echo "WARNING env var CRAFT_GP_DATA not set" >&2
fi
if [ -z "$CRAFT_GP_SCRIPTS" ] ; then
    echo "WARNING env var CRAFT_GP_SCRIPTS not set" >&2
fi
if [ -z "$(which tabix 2>/dev/null)" ] ; then
    echo "WARNING program tabix not found on PATH" >&2
fi
if [ ! -z "$(python -c 'import pandas' 2>&1)" ] ; then
    echo "WARNING python module pandas cannot be imported" >&2
fi
echo "Installing data into $TOP_DIR/source_data"
VEP_GRCh37_84_core_cache $TOP_DIR
CADD_plugin_data $TOP_DIR
Roadmap_Epigenomics_15_state_model $TOP_DIR
HapMap_recombination_map $TOP_DIR
UCSC_cytogenetic_bands $TOP_DIR
##
#
