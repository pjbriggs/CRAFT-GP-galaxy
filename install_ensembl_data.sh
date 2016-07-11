#!/bin/bash -e
#
# Install the reference data for CRAFT-GP for testing from command line
#
if [ -z "$CRAFT_GP_DATA" ] ; then
    echo CRAFT_GP_DATA: not set >&2
    exit 1
fi
if [ ! -d ${CRAFT_GP_DATA}/ensembl/cache/homo_sapiens ] ; then
    if [ ! -f homo_sapiens_vep_84_GRCh38.tar.gz ] ; then
	echo Downloading GRCh38 core cache
	wget -q ftp://ftp.ensembl.org/pub/release-84/variation/VEP/homo_sapiens_vep_84_GRCh38.tar.gz
    fi
    echo Unpacking GRCh38 core cache
    tar zxf homo_sapiens_vep_84_GRCh38.tar.gz -C ${CRAFT_GP_DATA}/ensembl/cache
fi
##
#
