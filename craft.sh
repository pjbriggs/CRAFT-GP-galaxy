#!/bin/bash -e
#
# Wrapper script for CRAFT(-GP) credible SNP annotation pipeline
# https://github.com/johnbowes/CRAFT-GP
# This script based on the run-all.sh script from that repo

echo "### CRAFT pipeline: starting ###"

# Initialise vars
INDEX_SNP_FILE=
SUMMARY_STATS_FILE=
DISTANCE_TYPE=
DISTANCE=
CASES=
CONTROLS=
EPIGENOMES_TYPE=
EPIGENOMES=
OUTPUT_DIR=

# Handle inputs
usage() {
    echo "Usage: $(basename $0) options INDEX_SNP_FILE SUMMARY_STATS_FILE"
    echo "Options"
    echo "  -n NAME"
    echo "  -m|-c DISTANCE"
    echo "  -a CASES"
    echo "  -u CONTROLS"
    echo "  -t EPIGENOMES_TYPE ('list' or 'group')"
    echo "  -e EPIGENOMES"
    echo "  -o OUTPUT_DIR"
}
while getopts ":n:m:c:a:u:t:e:o:h" opt ; do
    case "$opt" in
	n)
	    NAME="${OPTARG}"
	    ;;
	m|c)
	    if [ ! -z "$DISTANCE_TYPE" ] ; then
		echo "Distance type specified multiple times" >&2
		exit 1
	    fi
	    DISTANCE_TYPE="-$opt"
	    DISTANCE="${OPTARG}"
	    ;;
	a)
	    CASES="${OPTARG}"
	    ;;
	u)
	    CONTROLS="${OPTARG}"
	    ;;
	t)
	    EPIGENOMES_TYPE="${OPTARG}"
	    if [ "$EPIGENOMES_TYPE" != "list" ] && [ "$EPIGENOMES_TYPE" != "group" ] ; then
		echo "$EPIGENOMES_TYPE: unrecognised epigenome type" >&2
		exit 1
	    fi
	    ;;
	e)
	    EPIGENOMES="${OPTARG}"
	    ;;
	o)
	    OUTPUT_DIR="${OPTARG}"
	    ;;
	h)
	    usage
	    exit 0
	    ;;
	:)
	    echo "-${OPTARG}: missing required argument" >&2
	    exit 1
	    ;;
	*)
	    usage
	    echo "Unrecognised option supplied" >&2
	    exit 1
	    ;;
    esac
done
shift $(expr $OPTIND - 1)
INDEX_SNP_FILE=$1
SUMMARY_STATS_FILE=$2

# Checks
for f in "$INDEX_SNP_FILE" "$SUMMARY_STATS_FILE" ; do
    if [ -z "$f" ] ; then
	usage
	echo "One or more input files not supplied" >&2
	exit 1
    fi
    if [ ! -f $f ] ; then
	echo "$f: file not found"
	exit 1
    fi
done

# Set output dir
if [ -z "$OUTPUT_DIR" ] ; then
    if [ -z "$NAME" ] ; then
	OUTPUT_DIR="results"
    else
	OUTPUT_DIR="${NAME}_results"
    fi
fi

# Report settings
echo "### Tool settings ###"
echo Tool wrapper: $0
echo CRAFT script dir: $CRAFT_GP_SCRIPTS
echo Index SNP file: $INDEX_SNP_FILE
echo Summary stats file: $SUMMARY_STATS_FILE
echo Options:
echo Name: $NAME
echo Distance type: $DISTANCE_TYPE
echo Distance: $DISTANCE
echo Cases: $CASES
echo Controls: $CONTROLS
echo Epigenome type: $EPIGENOMES_TYPE
echo Epigenome names: $EPIGENOMES
echo Top level output directory: $OUTPUT_DIR

# Set up output directories
mkdir -p ${OUTPUT_DIR}/{regions,credible_snps,plots,annotation,bed}/

# Calculate genomic regions for defined distance
echo "### Calculating genomic regions ###"

ruby $CRAFT_GP_SCRIPTS/define_regions_main.rb \
     -i "$INDEX_SNP_FILE" \
     $DISTANCE_TYPE $DISTANCE \
     -o ${OUTPUT_DIR}/regions/ \
    2>&1
status=$?
if [ $status -ne 0 ] ; then
    echo ERROR define_regions_main.rb: non-zero exit code: $status >&2
    exit $status
fi

REGIONS=$(ls ${OUTPUT_DIR}/regions/*_boundaries_*.txt)

echo Regions: $REGIONS
echo "--- Outputs ---"
find -name "*" -type f

# Subset GWAS data
echo "### Subsetting GWAS data ###"

GWAS_SUBSET="${OUTPUT_DIR}/credible_snps/summary_stats_subset.txt"

python $CRAFT_GP_SCRIPTS/filter_summary_stats.py \
    --regions $REGIONS \
    --stats "$SUMMARY_STATS_FILE" \
    --out $GWAS_SUBSET \
    2>&1
status=$?
if [ $status -ne 0 ] ; then
    echo ERROR filter_summary_stats.py: non-zero exit code: $status >&2
    exit $status
fi
echo "--- Outputs ---"
find -name "*" -type f

# Calculate credible SNP sets
echo "### Calculating credible SNP sets ###"

Rscript --vanilla $CRAFT_GP_SCRIPTS/credible_snps_main.R \
    -r $REGIONS \
    -a $CASES \
    -u $CONTROLS \
    -s $GWAS_SUBSET \
    -o ${OUTPUT_DIR}/credible_snps/ \
    -b ${OUTPUT_DIR}/bed/ \
    2>&1
status=$?
if [ $status -ne 0 ] ; then
    echo ERROR credible_snps_main.R: non-zero exit code: $status >&2
    exit $status
fi
echo "--- Outputs ---"
find -name "*" -type f

# Make the reference data available from working dir
if [ ! -d source_data ] ; then
    ln -s $CRAFT_GP_DATA source_data
fi

# Annotation
echo "### Fetching annotation ###"

CREDIBLE_SNPS="${OUTPUT_DIR}/credible_snps/credible_snps_0.99.txt"

python $CRAFT_GP_SCRIPTS/annotation.py \
    --input $CREDIBLE_SNPS \
    --output ${OUTPUT_DIR}/annotation/annotation \
    --epi_names $EPIGENOMES \
    --epi_type $EPIGENOMES_TYPE \
    2>&1
status=$?
if [ $status -ne 0 ] ; then
    echo ERROR annotation.py: non-zero exit code: $status >&2
    exit $status
fi
echo "--- Outputs ---"
find -name "*" -type f

# Visualisation
echo "### Generating plots ###"

SUMMARY_TABLE="${OUTPUT_DIR}/credible_snps/summary_table_0.99.txt"
ANNOTATED_EPIGENOMES="${OUTPUT_DIR}/annotation/annotation.epigenomes"

Rscript --vanilla $CRAFT_GP_SCRIPTS/visualisation_main.R \
    -r $SUMMARY_TABLE \
    -s $CREDIBLE_SNPS \
    -e $ANNOTATED_EPIGENOMES \
    -o ${OUTPUT_DIR}/plots/ \
    2>&1
status=$?
if [ $status -ne 0 ] ; then
    echo ERROR visualisation_main.R: non-zero exit code: $status >&2
    exit $status
fi
echo "--- Outputs ---"
find -name "*" -type f

# Make a HTML file with all the PNG plots
echo "### Building HTML container for PNGs ###"
cat >${OUTPUT_DIR}/plots/plots.html <<EOF
<html>
<head><title>PNG plots</title></head>
<body>
EOF
PNGS=$(ls ${OUTPUT_DIR}/plots/*.png 2>/dev/null)
if [ -z "$PNGS" ] ; then
    echo WARNING no PNGS found >&2
    cat >>${OUTPUT_DIR}/plots/plots.html <<EOF
<p>No plots found</p>
EOF
else
    for png in $PNGS ; do
	png=$(basename $png)
	plot_name=${png%.*}
	cat >>${OUTPUT_DIR}/plots/plots.html <<EOF
<h1>$plot_name</h1>
<p><img src="$png" title="$plot_name" /></p>
EOF
    done
fi
cat >>${OUTPUT_DIR}/plots/plots.html <<EOF
</body>
</html>
EOF
echo "--- Outputs ---"
find -name "*" -type f
echo "### CRAFT pipeline: finished ###"
