#!/bin/sh -e
#
# Regenerate the macro file with options for epigenome groups
# and names
#
if [ -z "$1" ] ; then
    echo Usage: $(basename $0) FILE
    exit
fi
echo "<!-- Generated by $(basename $0) using $1 -->"
echo "<macros>"
echo "  <xml name=\"epigenomes_groups_options\">"
EPIGENOMES_GROUPS="$(cut -d, -f2 $1 | tr -s ' ' '?' | tail -n +2 | sort -u)"
for grp in $EPIGENOMES_GROUPS ; do
    grp="$(echo ${grp} | tr -s '?' ' ' | sed 's/&/&amp;/g')"
    echo "    <option value=\"${grp}\">${grp}</option>"
done
echo "  </xml>"
echo "  <xml name=\"epigenomes_list_options\">"
EPIGENOMES_NAMES="$(cut -d, -f6 $1 | tr -s ' ' '?' | tail -n +2 | sort)"
for name in $EPIGENOMES_NAMES ; do
    name="$(echo ${name} | tr -s '?' ' ' | sed 's/&/&amp;/g')"
    echo "    <option value=\"${name}\">${name}</option>"
done
echo "  </xml>"
echo "</macros>"
##
#
