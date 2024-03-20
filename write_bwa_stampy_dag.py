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
ref = "27Feb23-15-FR326N_ref.fasta.tgz"
out = "bwa_stampy_15.dag"
sa_code  = "C"


def get_sample_name(dir):
    '''
    From directory get sample name 
    '''
    spl = dir.split("/")
    return( spl[len(spl)-1] )


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


mapping_jobs_from_folder(sub, ref, dir, out, sa_code)

