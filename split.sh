# File names are like 25Feb23-1-ZI254N_S393_L002_R2_001_Block00251.fastq 

FILE="25Feb23-1-ZI254N_S393_L002_R1_001.fastq.gz"
SHORT=` echo ${FILE} | sed 's/.fastq.*/_Block/' `

zcat 25Feb23-1-ZI254N_S393_L002_R1_001.fastq.gz | head -n 420 | 
split -a 5 --additional-suffix=".fastq" -d -l 40  --filter='gzip > $FILE.gz' - ${SHORT}

