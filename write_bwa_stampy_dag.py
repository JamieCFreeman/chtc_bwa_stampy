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



dir = "/home/jcfreeman2/chtc_align/input_fastq/27Feb23-15-FR360N"

#dir = "/raid10/jamie/FR_N_genomes/27Feb23-16-ZI250N"


########################################################################

# Import package os and function compress from itertools

try:
	import os
except ImportError as e:
    print("Error -> ", e)

    
try:
	from itertools import compress
except ImportError as e:
    print("Error -> ", e)

#########################################################################

sub = "bwa_stampy.sub"
#ref = "27Feb23-15-FR326N_ref.fasta.tgz"
out = "bwa_stampy_15.dag"
sa_code  = "C"
round = 2

def get_sample_name(folder):
    '''
    From directory get sample name 
    '''
    spl = dir.split("/")
    return( spl[len(spl)-1] )

def get_ref(folder, round):
    '''
    If no ref is provided, give default based on my naming conventions
    '''
    if round == 1:
        return("DmelRef.fasta.tgz")
    elif round == 2:
        return( get_sample_name(folder) + "_ref.fasta.tgz" )

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
		job_list = [ sa_code + str(i) for i in range(len(R1_list)) ]
		job_str = ' '.join(job_list)
		f.write("JOB " + sa_code + " hello_chtc.sub" + '\n')
		f.write("PARENT " + job_str +  " CHILD " + sa_code + '\n')
		f.write("SCRIPT POST " + sa_code + " cleanup.sh " + '"' + sample_dir + '"' + '\n')

def merge_jobs_from_folder(merge_max, sub_file, folder, sample_code):
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
	bams = [R1_list[i].split("R1")[0] + "remapped." + R1_list[i].split("_")[5].split(".")[0] + ".bam"  for i in range(0,len(R1_list))]
	bam_lists = [bams[x:x+merge_max] for x in range(0, len(bams), merge_max)]
	
	# Write temporary files with merge lists
	for i in range(len(bam_lists)):
		temp_merge = "merge_list" + sa_code + str(i)
		with open(temp_merge, 'w') as f:
			f.write('\n'.join(bam_lists[i]))
		with open("test.dag", 'a') as f:
			job_now =  sa_code + "_merge" + str(i)
			f.write( "JOB " + job_now + " " + sub_file + '\n' )
			f.write( "SCRIPT PRE " + job_now + " gather_merge.sh " + temp_merge + '\n' )
			f.write( "SCRIPT POST " + job_now + " merge_POST.sh " + temp_merge + '\n' )
			f.write( "VARS " + job_now + " file_list=" + '"' + temp_merge + '"' + '\n' )


#mapping_jobs_from_folder(sub, get_ref(dir, round), dir, out, sa_code)

merge_jobs_from_folder(30,  "merge.sub", dir, sa_code)

