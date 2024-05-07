#!/bin/bash

##################################################################################################

# Update 2023 JCF

# For runs on CHTC, split fastq file into blocks that can be mapped individually as 
#	separate jobs. This is my implementation of Jeremy's? legacy perl script
#	split.pl. Edited in order to gzip output files on stream to save space.


###################################################################################################

# Input

FOLDER=$1
#FILE=`find ${FOLDER} -type f -iname "*R1*" |  sed 's /.*/  ' `
#FOLDER="/home/jcfreeman2/chtc_align/input_fastq/25Feb23-2-ZI418N"
#FILE="25Feb23-1-ZI254N_S393_L002_R2_001.fastq.gz"
N_LINES="750000"


####################################################################################################
# Define a function to split fq, check output, and clean up.

function split_fq_gz {
  #From folder & readset get file name
  FILE=`find ${FOLDER} -type f -iname "*_${READ_SET}_*" ! -iname "*Block*" |  sed 's /.*/  ' `
  echo "Running split for ${FILE}"
  # Get file prefix for output block names
  SHORT=` echo ${FOLDER}/${FILE} | sed 's/.fastq.gz/_Block/' `
  # File names are like 25Feb23-1-ZI254N_S393_L002_R2_001_Block00251.fastq 

  # Split file (and gzip output files)
  zcat ${FOLDER}/${FILE} | 
    split -a 5 --additional-suffix=".fastq" -d -l ${N_LINES}  --filter='gzip > $FILE.gz' - ${SHORT}

  # How many reads should there be in the combined file?
  # 1. Every block except the last should have N_LINES /4 reads
  n_files=`find ${FOLDER} -maxdepth 1 -mindepth 1 -type f -iname "*Block*" -iname "*_${READ_SET}_*" | wc -l`
  reads_per_split=$(echo $(( ${N_LINES} / 4 )) )
  echo "There are $n_files block files for ${FILE}."
  # 2. Need to count lines from the last file to get it's read number
  last_file=$(zcat $(find ${FOLDER} -maxdepth 1 -mindepth 1 -type f -iname "*Block*" \
    -iname "*_${READ_SET}_*" | sort -V | tail -n 1) | wc -l)
  # 3. Total reads output is equal to (the n of block files) * (reads per block) + ((lines of last file) /4 )
  total_reads_output=$( echo $(( ((${n_files} - 1) * ${reads_per_split}) + (last_file / 4) )) )
  echo "${total_reads_output} reads are in the block files for ${FILE}"

  # How many reads are in the input file?
  total_reads_input=$( echo $(( $(zcat ${FOLDER}/${FILE} | wc -l ) / 4 )) )
  echo "${total_reads_input} reads were input."

  # If number of reads is what it should be, delete input files
  if [ ${total_reads_output} -eq ${total_reads_input} ]; then
    echo "${FILE} block files contains all reads input";
    echo "Deleting fastq for ${FILE}";
    rm ${FOLDER}/${FILE};
  else
    echo "${FOLDER} block files are missing reads!! Check output before proceeding"
  fi

}


###########################################################################################

# Run for both R1 & R2 files
READ_SET="R1"
split_fq_gz &

READ_SET="R2"
split_fq_gz


