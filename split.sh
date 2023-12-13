# File names are like 25Feb23-1-ZI254N_S393_L002_R2_001_Block00251.fastq 

FOLDER="/home/jcfreeman2/chtc_align/input_fastq/25Feb23-1-ZI254N"
FILE="25Feb23-1-ZI254N_S393_L002_R2_001.fastq.gz"


SHORT=` echo ${FOLDER}/${FILE} | sed 's/.fastq.gz/_Block/' `
N_LINES="500000"

# Split file (and gzip output files)
zcat ${FOLDER}/${FILE} | 
  split -a 5 --additional-suffix=".fastq" -d -l ${N_LINES}  --filter='gzip > $FILE.gz' - ${SHORT}

# How many reads should there be in the combined file?
# 1. Every block except the last should have N_LINES /4 reads
n_files=`find ${FOLDER} -maxdepth 1 -mindepth 1 -type f -iname "*Block*" | wc -l`
reads_per_split=$(echo $(( ${N_LINES} / 4 )) )
echo "There are $n_files block files."
# 2. Need to count lines from the last file to get it's read number
last_file=$(zcat $(find ${FOLDER} -maxdepth 1 -mindepth 1 -type f  -iname "*Block*" | sort -V | tail -n 1) | wc -l)
# 3. Total reads output is equal to (the n of block files) * (reads per block) + ((lines of last file) /4 )
total_reads_output=$( echo $(( ((${n_files} - 1) * ${reads_per_split}) + (last_file / 4) )) )
echo "${total_reads_output} reads are in the block files"

# How many reads are in the input file?
total_reads_input=$( echo $(( $(zcat ${FOLDER}/${FILE} | wc -l ) / 4 )) )
echo "${total_reads_input} reads were input."

# If number of reads is what it should be, delete block files
  if [ ${total_reads_output} -eq ${total_reads_input} ]; then
    echo "${FOLDER} block files contains all reads input";
    echo "Deleting fastq for ${FOLDER}";
    rm ${FOLDER}/${FILE};
  else
    echo "${FOLDER} block files are missing reads!! Check output before proceeding"
  fi

