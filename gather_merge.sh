#!/bin/bash

# Argument islist of files to merge
INPUT=$1

# Tar input files and send archive to staging
tar -cf ${INPUT}.tar.gz -T ${INPUT}
mv ${INPUT}.tar.gz /staging/jcfreeman2/

