#!/usr/bin/perl -w

if(@ARGV != 3){
   die "This script requires three arguments in this order: name of submit file, output name of dag file, name of the tarred reference genome\n"; 
}

$sub_file=$ARGV[0];
$dag_file=$ARGV[1];
$ref_genome=$ARGV[2];
@output=();

chdir("./input_fastq");
@input_dirs=`ls -p | grep "/"`;
chomp @input_dirs;

for($i=0;$i<@input_dirs;$i++){
   if($input_dirs[$i] eq 'shared/'){
      splice @input_dirs, $i, 1;
   }
}

$iter=0;
for($d=0;$d<@input_dirs;$d++){
   chdir($input_dirs[$d]);
   @fastq=glob("*_R1_*Block*fastq.gz");
   for($i=0;$i<@fastq;$i++){
      @arr=split /_/, $fastq[$i];
      $block_id=substr($arr[-1],0,10);
      @arr=split /_R1_/, $fastq[$i];
      $unique_str1=$arr[0];
      $unique_str2=$arr[1];

      $str="JOB $iter $sub_file\n";
      push @output, $str;
      $str="VARS $iter ref=\"$ref_genome\"\n";
      push @output, $str;
      $str="VARS $iter fastq1=\"$input_dirs[$d]".$unique_str1."_R1_".$unique_str2."\"\n";
      push @output, $str;
      $str="VARS $iter fastq2=\"$input_dirs[$d]".$unique_str1."_R2_".$unique_str2."\"\n";
      push @output, $str;
      $str="VARS $iter block_id=\"".$unique_str1."_".$block_id."\"\n";
      push @output, $str;
      
      $iter++;
   }
   chdir("../");
}
chdir("../");
open O, ">$dag_file";
for($i=0;$i<@output;$i++){
   print O "$output[$i]";
}
close O;

