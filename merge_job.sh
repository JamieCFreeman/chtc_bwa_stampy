#!/bin/bash

# Executable for bam merging jobs 
# Purpose: Transfers a tar archive of bams from staging, untars, merges all bams contained,
#		writes flagstat input to std out for POST script parsing, cleans up.

# Unpack software
mkdir ./pipeline_run
mv pipeline_software.tgz ./pipeline_run
cd ./pipeline_run

# Print variables to std out for debugging
echo "${0} is arg 0"
echo "${1} is arg 1"
echo "${2} is arg 2"

# Input variables should be:
#	1. file name of the tar archive to be merged
#	2. number of directories to be stripped off of the front end when untarring 
#		(different between first and second merge)
MERGE_FILE=${1}
STRIP_DIR=${2}

# Grab input tar from staging and extract
echo "Copying input /staging/jcfreeman2/${MERGE_FILE}.tar.gz from staging"
cp /staging/jcfreeman2/${MERGE_FILE}.tar.gz .

tar -xf pipeline_software.tgz
tar -xf ${MERGE_FILE}.tar.gz --strip=${STRIP_DIR}
rm ${MERGE_FILE}.tar.gz
ls -lh

# Merge bams and check
SAMT_PATH="$(pwd)/samtools/bin"
${SAMT_PATH}/samtools merge ${MERGE_FILE}.bam *.bam
${SAMT_PATH}/samtools flagstat ${MERGE_FILE}.bam

# Transfer output and cleanup
mv ${MERGE_FILE}.bam /staging/jcfreeman2/
cd ..
rm -rf ./pipeline_run




