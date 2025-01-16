#!/bin/bash

# Argument islist of files to merge
INPUT=$1

# Tar input files and send archive to staging,
#	upon successful archive creation, delete block files
tar --remove-files -cf ${INPUT}.tar.gz -T ${INPUT}
mv ${INPUT}.tar.gz /staging/jcfreeman2/

