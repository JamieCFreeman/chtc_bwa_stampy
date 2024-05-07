#!/bin/bash

# Argument is sample code
INPUT=$1

# Tar input files and send archive to staging
tar -cvf ${INPUT}.tar.gz /staging/jcfreeman2/merge_list${1}*.bam
mv ${INPUT}.tar.gz /staging/jcfreeman2/

