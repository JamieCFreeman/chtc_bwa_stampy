#!/bin/bash


# Either split fq files into blocks here or transfer tar.gz of split sample fqs

# Untar files
#find ./input_fastq -maxdepth 1 -iname "*.tar.gz" | xargs -I % tar -xf % -C ./input_fastq
# find ./input_fastq -maxdepth 1 -iname "*.tar.gz" -exec rm {} \;

# Or if need to split here (runs only 1 at at time):
cd input_fastq
find . -maxdepth 1 -type f -iname "*_R1_*" | sed 's/_L.*//' | sed 's ./  ' | xargs -I % ../split.sh %



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

# Command for syncing back
# rsync -av --remove-source-files jcfreeman2@transfer.chtc.wisc.edu:/staging/jcfreeman2/"240322-*.bam" .

#periodic_release = (HoldReasonSubCode == 2)

