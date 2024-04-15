#!/bin/bash

# Argument is sample code
INPUT=$1

# Append folder name onto file list so they can be found by tar
#sed -i 's ^ outputs/ ' ${INPUT}

# Tar input files and send archive to staging
tar -cvf ${INPUT}.tar.gz /staging/jcfreeman2/merge_list${1}*.bam
mv ${INPUT}.tar.gz /staging/jcfreeman2/

