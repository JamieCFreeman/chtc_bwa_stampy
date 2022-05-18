use Cwd;

if(@ARGV != 2){
   die "incorrect number of inputs. Expected 2 in the form: path_to_output_dir and unique string identifying read set\n";
}

$output_dir=$ARGV[0];
$unique_str=$ARGV[1];

$cwd=cwd();
chdir($cwd."/".$output_dir);
mkdir("combine_bams_$unique_str");
system("cp $cwd/input_fastq/shared/pipeline_software.tgz ./combine_bams_$unique_str");
system("cp $unique_str*remapped*.bam ./combine_bams_$unique_str");
chdir("./combine_bams_$unique_str");
system("tar -xzf pipeline_software.tgz");

$shell="shell.sh";
open S, ">$shell";
print S '#!/bin/bash';
print S "\n";
print S "export PATH=".'$(pwd)'."/samtools/bin:".'$PATH';
print S "\n";
print S "samtools merge ".$unique_str.".bam *.bam\n";
close S;

system("chmod +x $shell");
system("./$shell");
system("mv ".$unique_str.".bam ../");
chdir("../");
system("rm -rf ./combine_bams_$unique_str");

