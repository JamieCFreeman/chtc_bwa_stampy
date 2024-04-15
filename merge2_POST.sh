#!/bin/bash

# Argument is sample code
INPUT=$1

# For each job, we report the samtools flagstat to stdout, so python script
#   sums numbers from out files to get total
#PART_BAMS=`python sum_file.py "${INPUT}_combined_reads.tmp"`
FINAL_BAM=`grep "in total" ${INPUT}.out | awk '{print $1}'`

echo "partial bams total ${PART_BAMS} reads and final bam totals ${FINAL_BAM} reads"

BLOCK_LINES=` zcat $( find input_fastq/${INPUT} -type f | sort -V | head -n 1 ) | wc -l `
LAST_LINES=` zcat $( find input_fastq/${INPUT} -type f | sort -V | tail -n 1 ) | wc -l `

N_BLOCKS=` find input_fastq/${INPUT} -type f | sort -V  | wc -l `

BLOCK_READS=` python -c "print( ${BLOCK_LINES}/4) " `
LAST_READS=` python -c "print( ${LAST_LINES}/4) " `

echo "blocks are ${N_BLOCKS} of ${BLOCK_READS} reads and last is ${LAST_READS}"
INPUT_READS=` python -c "print( (${BLOCK_READS} * ( ${N_BLOCKS} -2 )) + ( ${LAST_READS}*2 )  )" `

RESULT=` python -c "print( ${FINAL_BAM} == ${INPUT_READS} )" `

if [ "${RESULT}" == "True" ]; then
	echo "removing";
	find /staging/jcfreeman2 -iname "merge_list${INPUT}*.bam" -exec rm {} \;
	find /staging/jcfreeman2 -iname "${INPUT}*.tar.gz" -exec rm {} \;
	find ./outputs -name "*remapped.Block*" -name "*.bam" -name "${INPUT}*" -exec rm {} \;
	find ./outputs -name "*${INPUT}*" \( -name "*.err" -o -name "*.log"  -o -name "*.out" \) -exec \
		    tar -czf ./outputs/${INPUT}_chtc_logs.tar.gz {} \;
	find . -iname "merge_list${INPUT}*" -exec rm {} \;
	find . -iname "${INPUT}.log" -exec rm {} \;
else
	echo "Final bam for ${INPUT} has ${FINAL_BAM} reads, but block fastq files total ${INPUT_READS}"
fi

