#!/bin/bash

# Argument is sample string
FOLDER=$1

# First do a quick check that the number of bam files = the number jobs submitted.
# 	If this is TRUE, continue, otherwise exit.
N_BAMS=$( find ./outputs/ -name "*.bam" -name "*Block*" -name "*${FOLDER}*" | wc -l )
N_OUT=$( find ./outputs/ -name "*.log" -name "*Block*" -name "*${FOLDER}*" | wc -l )

if [ ${N_BAMS} -eq ${N_OUT} ]; then
  echo "All expected output bams exist ";
else
  echo >&2 "For ${FOLDER} there should be ${N_OUT} bams, but there are ${N_BAMS}. Check output before proceeding"; exit 1; 
fi

# Stampy error ends up with a bam files that has header and nothing else, so just b/c bam is there 
#  doesn't mean we can trust it. Check the number of reads.

  echo "combining bams for ${FOLDER}"; 
  # Need to set max number of files to combine at once, too many causes error
  MAX_OPEN_BAMS=250
  
  # Split block bams into lists of 250
  find ./outputs -iname "*.bam" -iname "*Block*" -iname "${FOLDER}*" | sort -V | split -l ${MAX_OPEN_BAMS} - ${FOLDER}_out
  #perl combine_bams.pl ./outputs ${FOLDER};   
  samtools_path="/home/jcfreeman2/chtc_align/input_fastq/shared/pipeline_software/samtools/bin/samtools"
  
  # Combine partial bams
  while IFS= read -r FILE_LIST; do
    echo "${samtools_path} merge ${FILE_LIST}.bam -b ${FILE_LIST}"; \
     ${samtools_path} merge ${FILE_LIST}.bam -b ${FILE_LIST}; \
  done < <( find -iname "${FOLDER}*" -iname "*_out*" ! -iname "*.bam" )
  
  # If multiple partial bams exist, merge then.
  # 1. count partial bams 
  PART_BAMS=`find . -iname "${FOLDER}_outa*.bam" | wc -l`
  if [ "${PART_BAMS}" -gt "1" ]; then
    echo "merging partial bams for ${FOLDER}"
    ${samtools_path} merge ./outputs/${FOLDER}.bam ${FOLDER}_outa*.bam
    else
      echo "just one bam for ${FOLDER}"
      mv ${FOLDER}_outaa.bam ./outputs/${FOLDER}.bam
    fi
  echo "checking combined bam for ${FOLDER}";
  ${samtools_path} flagstat ./outputs/${FOLDER}.bam > tmp.${FOLDER}_combined.stats;

  # How many reads should there be in the combined file?
  n_files=`find ./input_fastq/${FOLDER} -maxdepth 1 -mindepth 1 -type f -iname "*Block*" | wc -l`
  last_file=$(zcat $(find ./input_fastq/${FOLDER} -maxdepth 1 -mindepth 1 -type f | sort -V | tail -n 1) | wc -l)
  reads_per_split=$( ${samtools_path} flagstat \
                       $(find ./outputs -iname "*.bam" -iname "*Block*" -iname "${FOLDER}*" | sort -V | head -n 1 ) | \
                       grep "read1" | sed 's/ +.*//' )
  bam_reads=$(head -n 1 tmp.${FOLDER}_combined.stats | sed 's/ +.*//')
  total_reads_input=$(echo $(( ((${n_files} - 2) * ${reads_per_split}) + ((last_file / 4) * 2) )))

  # If number of reads is what it should be, delete block files
  if [ ${bam_reads} -eq ${total_reads_input} ]; then
    echo "${FOLDER}.bam contains all reads input";
    echo "Deleting block bams for ${FOLDER}";
    #find ./outputs -name "*remapped.Block*" -name "*.bam" -name "$FOLDER*" -exec rm {} \;
    find ./outputs -name "*remapped.Block*" -name "*.bam" -name "$FOLDER*" -exec tar -czf ./outputs/${FOLDER}_bams.tar.gz {} \;
    find -iname "${FOLDER}*" -iname "*_out*" -exec rm {} \;
    echo "tarring logs for ${FOLDER}";
    find ./outputs -name "*$FOLDER*" \( -name "*.err" -o -name "*.log"  -o -name "*.out" \) -exec \
    tar -czf ./outputs/${FOLDER}_chtc_logs.tar.gz {} \;
    echo "Cleaning up log files"
    find ./outputs -name "*$FOLDER*" \( -name "*.err" -o -name "*.log"  -o -name "*.out" \) -exec rm {} \;
    rm tmp.${FOLDER}_combined.stats;
  else
    echo "${FOLDER}.bam is missing reads!! Has ${bam_reads} but expected ${total_reads_input}. Check output before proceeding"
  fi

