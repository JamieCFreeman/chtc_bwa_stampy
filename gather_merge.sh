#!/bin/bash

# Argument is list of files to merge
INPUT=$1

# Check whether all files exist
ALL_HERE=`python scripts/all_exist.py ${INPUT}`

if [[ "${ALL_HERE}" == "True" ]]; then
  echo "go"
  # Tar input files and send archive to staging,
  #	upon successful archive creation, delete block files
  tar --remove-files -cf ${INPUT}.tar.gz -T ${INPUT}
  mv ${INPUT}.tar.gz /staging/jcfreeman2/
else
  echo "Some input files are missing for merge ${INPUT}"
  exit 1 # terminate and indicate error
fi

# Tar input files and send archive to staging,
#	upon successful archive creation, delete block files
#tar --remove-files -cf ${INPUT}.tar.gz -T ${INPUT}
#mv ${INPUT}.tar.gz /staging/jcfreeman2/

