#!/bin/bash



# For the directories in input_fastq (excluding itself & the shared folder), 
# 	unzip fastq.gz files first!! (should edit function to check & exit if not),
#	run split script
while read FOLDER; do
  echo "${FOLDER}"; gunzip ${FOLDER}/* ; perl split.pl 500000 ${FOLDER}
done < <(find ./input_fastq -maxdepth 1 -mindepth 1 -type d | sed '/shared/d')

# Append dag file name with date & time, so each has unique ID
# Prepare dag file
NOW=`date +'%Y_%m_%d_%H:%M'`
perl prepare_dag.pl bwa_stampy.sub bwa_stampy_${NOW}.dag DmelRef.fasta.tgz

# Submit dag file to queue
condor_submit_dag bwa_stampy_${NOW}.dag

