#usr/bin/python

########################################################################
# March 2024 JCF
########################################################################

########################################################################
#
# Purpose:
# 	To write dag file for split mapping on CHTC using the DGN legacy pipeline
#	(mapping with bwa aln and then remapping poor quality maps with stampy).
#	Reimplementation of Jeremy's script prepare_dag.pl to include cleanup
# 	post script on a per sample basis.
#
#########################################################################


#dir = sys.argv[1]

#dir = "/home/jcfreeman2/chtc_align/input_fastq/21Oct22-7-ZI193N"
#dir = "/home/jcfreeman2/chtc_align/input_fastq/ZI418N_SRA"

########################################################################

# Import package os and function compress from itertools

try:
	import os
except ImportError as e:
    print("Error -> ", e)
    
try:
	import sys
except ImportError as e:
    print("Error -> ", e)

try:
	from itertools import compress
except ImportError as e:
    print("Error -> ", e)

#########################################################################

dir = sys.argv[1]

sub = "bwa_stampy.sub"
round = 2

def get_sample_name(folder):
    '''
    From directory get sample name 
    '''
    spl = dir.split("/")
    return( spl[len(spl)-1] )

sa_code  = get_sample_name(dir)
out = "bwa_stampy_" + get_sample_name(dir) + ".dag"

def get_ref(folder, round):
    '''
    If no ref is provided, give default based on my naming conventions
    '''
    if round == 1:
        return("DmelRef.fasta.tgz")
    elif round == 2:
        return( get_sample_name(folder) + "_ref.fasta.tgz" )

def write_inline_submit(sub_file, name, exc, in_dir, trans_in, args, out_pattern, cpu, ram, disk, trans_exc="true", uni="container", cont_im="file:///staging/jcfreeman2/osgvo-el7.sif"):
	'''
	Write inline submit description for dag
    '''
	with open(sub_file, 'w') as f:
		f.write( "SUBMIT-DESCRIPTION " + name + " {" + '\n' )
		f.write( '\t' + f"{'executable' :<25} = {exc}" + '\n')
		f.write( '\t' + f"{'initialdir' :<25} = {in_dir}" + '\n')
		f.write( '\t' + f"{'transfer_executable' :<25} = {trans_exc}" +'\n')
		f.write( '\t' + f"{'transfer_input_files' :<25} = {trans_in}" +'\n')
		f.write( '\t' + f"{'when_to_transfer_output' :<25} = ON_EXIT_OR_EVICT" +'\n')
		f.write( '\t' + f"{'arguments' :<25} = {args}" + '\n')
		f.write( '\t' + f"{'output' :<25} = {out_pattern}.out" +'\n')
		f.write( '\t' + f"{'error' :<25} = {out_pattern}.err" +'\n')
		f.write( '\t' + f"{'log' :<25} = {out_pattern}.log" +'\n')
		f.write( '\t' + f"{'universe' :<25} = {uni}" +'\n')
		f.write( '\t' + f"{'Requirements' :<25} = (Target.HasCHTCStaging == true)" +'\n')
		f.write( '\t' + f"{'container_image' :<25} = {cont_im}" +'\n')
		f.write( '\t' + f"{'request_cpus' :<25} = {cpu}" +'\n')
		f.write( '\t' + f"{'request_memory' :<25} = {ram}" +'\n')
		f.write( '\t' + f"{'request_disk' :<25} = {disk}" +'\n')
		f.write( '\t' + f"{'stream_output' :<25} = false" +'\n')
		f.write( "}" + '\n' )

#write_inline_submit("test.txt", name="SampleMerge", exc="/home/jcfreeman2/chtc_align/merge_job.sh", in_dir="/home/jcfreeman2/chtc_align", trans_in="/home/jcfreeman2/chtc_align/input_fastq/shared/pipeline_software.tgz", args="", out_pattern="$(file_list)", cpu="1", ram="1296", disk="25000000" )

#write_inline_submit("test2.txt", name="MapBlocks", exc="/home/jcfreeman2/chtc_align/bwa_stampy.pl", in_dir="/home/jcfreeman2/chtc_align/outputs", trans_in="/home/jcfreeman2/chtc_align/input_fastq/shared/pipeline_software.tgz,/home/jcfreeman2/chtc_align/input_fastq/shared/$(ref),/home/jcfreeman2/chtc_align/input_fastq/$(fastq1),/home/jcfreeman2/chtc_align/input_fastq/$(fastq2)", args="$(file_list) $(strip)", out_pattern="bwa_stampy_$(block_id)", cpu="1", ram="1000", disk="8000000")

def mapping_jobs_from_folder(sub_file, ref_file, folder, out_file, sample_code):
	'''
	Write to file sub_file mapping jobs for block fastq files present in
	folder
	'''
	# Get block files from dir
	files = sorted( os.listdir(dir) ) 
	
	# Directory contains R1 and R2 files- get lists of both
	R1_bool = [ "_R1_" in f for f in files ]
	R2_bool = [ f is False for f in R1_bool ]
#
	R1_list = list( compress(files, R1_bool) )
	R2_list = list( compress(files, R2_bool) )
#	
	# Get sample_dir name
	sample_dir = get_sample_name(folder)

# Open file for writing and 
	with open(out_file, 'w') as f:
		for i in range(len(R1_list)):
			node_id = sample_code + str(i)
			f.write( "JOB " + node_id + " " + sub_file + '\n' )
			f.write( "VARS " + node_id  + " ref=" + '"' + ref_file + '"' + '\n' )
			f.write( "VARS " + node_id + " fastq1=" + '"' + sample_dir + "/" + R1_list[i] + '"' + '\n' )
			f.write( "VARS " + node_id + " fastq2=" + '"' + sample_dir + "/" + R2_list[i] + '"' + '\n' )
			s = R1_list[i]
			b_id = s[0:(len(s)-9)]
			f.write( "VARS " + node_id + " block_id=" + '"' + b_id + '"' + '\n' )
	    # Write merge jobs
		#job_list = [ sa_code + str(i) for i in range(len(R1_list)) ]
		#job_str = ' '.join(job_list)
		#f.write("JOB " + sa_code + " hello_chtc.sub" + '\n')
		#f.write("PARENT " + job_str +  " CHILD " + sa_code + '\n')
		#f.write("SCRIPT POST " + sa_code + " cleanup.sh " + '"' + sample_dir + '"' + '\n')

def get_block_fq(fq):
	# From fastq file name get block id
	spl1 = fq.split("_")
	return spl1[len(spl1)-1].split(".")[0]

def merge_jobs_from_folder(merge_max, sub_file, folder, out_dag, sample_code):
	# Get block files from dir
	files = sorted( os.listdir(dir) )
	
	# Directory contains R1 and R2 files- get lists of both
	R1_bool = [ "_R1_" in f for f in files ]
	R1_list = list( compress(files, R1_bool) )
	
	# Get sample_dir name
	sample_dir = get_sample_name(folder)
	
	# Set max number of files to merge
	merge_max = 30
	
	# Get job list for all mapping jobs
	job_list = [ sa_code + str(i) for i in range(len(R1_list)) ]
	
	# Split mapping jobs into lists of max lenth merge_max
	merge_lists = [job_list[x:x+merge_max] for x in range(0, len(job_list), merge_max)]
	merge_str = [' '.join(merge_lists[i]) for i in range( len(merge_lists) ) ]
	
	# Get bams for each merge job
	bams = ["outputs/" + R1_list[i].split("_R1_")[0] + "_remapped." + get_block_fq(R1_list[i]) + ".bam"  for i in range(0,len(R1_list))]
	bam_lists = [bams[x:x+merge_max] for x in range(0, len(bams), merge_max)]
	
	# Write temporary files with merge lists
	for i in range(len(bam_lists)):
		temp_merge = "merge_list" + sa_code + str(i)
		with open(temp_merge, 'w') as f:
			f.write('\n'.join(bam_lists[i]))
		with open(out_dag, 'a') as f:
			job_now =  sa_code + "_merge" + str(i)
			f.write( "JOB " + job_now + " " + sub_file + '\n' )
			f.write( "SCRIPT PRE " + job_now + " gather_merge.sh " + temp_merge + '\n' )
			f.write( "SCRIPT POST " + job_now + " merge_POST.sh " + temp_merge + '\n' )
			f.write( "VARS " + job_now + " file_list=" + '"' + temp_merge + '"' + '\n' )
			f.write( "VARS " + job_now + " strip=" + '"' + "1" + '"' + '\n' )
			f.write( "PARENT " + merge_str[i] + " CHILD " + job_now + '\n' )
    # Write sample-level merge job
	with open(out_dag, 'a') as f:
		f.write( "JOB " + sa_code + " SampleMerge" + '\n')
		f.write( "SCRIPT PRE " + sa_code + " merge2_PRE.sh " + sa_code + '\n')
		f.write( "SCRIPT POST " + sa_code + " merge2_POST.sh " + sa_code + '\n' )
		f.write( "VARS " + sa_code + " file_list=" + '"' + sa_code + '"' + '\n' )
		f.write( "VARS " + sa_code + " strip=" + '"' + "2" + '"' + '\n' )
		job_list = [sa_code + "_merge" + str(i) for i in range(len(bam_lists))]
		job_str = ' '.join(job_list)
		f.write( "PARENT " + job_str + " CHILD " + sa_code + '\n')


sa_code  = get_sample_name(dir)
out = "bwa_stampy_" + get_sample_name(dir) + ".dag"

mapping_jobs_from_folder(sub, get_ref(dir, round), dir, out, sa_code)

merge_jobs_from_folder(30,  "merge.sub", dir, out, sa_code)

