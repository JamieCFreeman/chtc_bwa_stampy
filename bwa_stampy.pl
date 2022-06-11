#!/usr/bin/perl -w

unless(-e "pipeline_software.tgz"){
   system("ls -l");
   die "did not find the tarred pipeline software files!\n";
}

@tarred_ref_genome=glob("*fasta.tgz");
if(@tarred_ref_genome==0){
   system("ls -l");
   die "tarred reference genome is missing or named incorrectly!\n";
}
@arr=split /.fasta/, $tarred_ref_genome[0];
$ref_string=$arr[0];

@tarred_fastq=glob("*fastq.gz");
if(@tarred_fastq != 2){
   system("ls -l");
   $num=@tarred_fastq;
   die "found an incorrect number of zipped fastq files! found $num when there should be 2\n";
}
@read1=split /.fastq/, $tarred_fastq[0];
@read2=split /.fastq/, $tarred_fastq[1];
@read_set=split /_R1_/, $read1[0];
if(@read_set == 0){
   die "issue with splitting up read names. Splitting on '_R1_' did not work\n"; 
}
@arr=split /_/, $read1[0];
$block_id=$arr[-1];

$shell="shell.sh";
open S, ">$shell";
print S '#!/bin/bash';
print S "\n";
print S "uname -r\n";
print S "mkdir pipeline_run\n";
print S "mv $ref_string.fasta.tgz ./pipeline_run\n";
print S "mv pipeline_software.tgz ./pipeline_run\n";
print S "mv *Block* ./pipeline_run\n";
print S "cd ./pipeline_run\n";
print S "tar -xzf $ref_string.fasta.tgz\n";
print S "tar -xzf pipeline_software.tgz\n";
print S "gzip -d $tarred_fastq[0]\n";
print S "gzip -d $tarred_fastq[1]\n";
print S "export PATH=".'$(pwd)'."/bwa-0.5.9rc1:".'$PATH';
print S "\n";
print S "bwa index -abwtsw $ref_string.fasta\n";
print S "bwa aln $ref_string.fasta $read1[0].fastq > $read1[0].sai\n";
print S "bwa aln $ref_string.fasta $read2[0].fastq > $read2[0].sai\n";
print S "bwa sampe -P $ref_string.fasta $read1[0].sai $read2[0].sai $read1[0].fastq $read2[0].fastq > $read_set[0]_$block_id.sam\n"; 
print S "export PATH=".'$(pwd)'."/samtools/bin:".'$PATH';
print S "\n";
print S "samtools view -bS $read_set[0]_$block_id.sam > $read_set[0]_$block_id.bam\n";
print S "echo flagstat $read_set[0]_$block_id.bam\n";
print S "samtools flagstat $read_set[0]_$block_id.bam\n";
print S "export PATH=".'$(pwd)'."/python/bin:".'$PATH';
print S "\n";
print S "./stampy.py -G $ref_string $ref_string.fasta\n";
print S "./stampy.py -g $ref_string -H $ref_string\n";
print S "./stampy.py -g $ref_string -h $ref_string --bamkeepgoodreads -M $read_set[0]_$block_id.bam -o $read_set[0]_remapped.$block_id.sam\n";
# Want to keep track of mapping percentage (the -q20 flag filters out unmapped/low qual alignments)
# Prev command: print S "samtools view -bS -q 20 $read_set[0]_remapped.$block_id.sam > $read_set[0]_remapped.$block_id.bam\n";
print S "samtools view -bS $read_set[0]_remapped.$block_id.sam > $read_set[0]_remapped.$block_id.bam\n";
print S "echo flagstat $read_set[0]_remapped.$block_id.bam\n";
print S "samtools flagstat $read_set[0]_remapped.$block_id.bam\n";


# Added sort step to speed up combining 
print S "samtools sort $read_set[0]_remapped.$block_id.bam -o $read_set[0]_remapped.sort.$block_id.bam\n";
print S "mv $read_set[0]_remapped.sort.$block_id.bam ../$read_set[0]_remapped.$block_id.bam \n";
print S "cd ../\n";
print S "rm -rf ./pipeline_run\n";
close S;

system("chmod +x $shell");
system("./$shell");
system("rm $shell");
