#!/bin/bash



# For the directories in input_fastq (excluding itself & the shared folder), 
# 	unzip fastq.gz files first!! (should edit function to check & exit if not),
#	run split script

# For fastq files in input_fastq, create directories for each sample, and move the appropriate files into them
#while read FOLDER; do
#  echo "${FOLDER}"; mkdir ${FOLDER}; mv "${FOLDER}"*.gz ${FOLDER}
#done < <( find ./input_fastq -iname "*.fastq*" -maxdepth 1 -mindepth 1 -type f | sed 's/_S[0-9][0-9][0-9]_L00[0-9]_.*//' | sort -V | uniq )





#while read FOLDER; do
#  echo "${FOLDER}"; gunzip ${FOLDER}/* ; perl split.pl 500000 ${FOLDER}
#done < <(find ./input_fastq -maxdepth 1 -mindepth 1 -type d | sed '/shared/d')



# Untar files
find ./input_fastq -maxdepth 1 -iname "*.tar.gz" | xargs -I % tar -xf % -C ./input_fastq
# find ./input_fastq -maxdepth 1 -iname "*.tar.gz" -exec rm {} \;


# Append dag file name with date & time, so each has unique ID
# Prepare dag file
NOW=`date +'%Y_%m_%d_%H:%M'`
perl prepare_dag.pl bwa_stampy.sub bwa_stampy_${NOW}.dag DmelRef.fasta.tgz

# Add POST scripts to dag
DAG="bwa_stampy_2023_12_21_06:56.dag"
#SAMPLE="27Feb23-4-FR264N"
#SAMPLE="27Feb23-5-FR54N"
#JOB_LIST=`grep block_id ${DAG} | grep ${SAMPLE} | sed 's/ block_id.*//' | sed 's/VARS //' | tr "\n" " " `
#POST_LINE=`echo "SCRIPT POST" ${JOB_LIST} "cleanup.sh" ${SAMPLE}`

#echo ${POST_LINE} >> ${DAG}

# Submit dag file to queue
#condor_submit_dag bwa_stampy_${NOW}.dag -maxpost 2

