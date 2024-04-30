#!/bin/bash

# Clean up after merging bams, but check number of reads is correct

# Argument is list of files to merge
INPUT=$1

#
TAR_DIR="/staging/jcfreeman2"

# Parse samtools flagstat output in .out file
READ_COUNT=`grep 'in total (QC' ${INPUT}.out | sed 's/ +.*//'`

# If read count is correct, then delete tar file
if [ "${READ_COUNT}" == "11250000" ]; then 
  echo "removing ${TAR_DIR}/${INPUT}.tar.gz"
  rm ${TAR_DIR}/${INPUT}.tar.gz
  fi

