# Implementation of the Drosophila Genome Nexus style 2-step mapping.

 1. Directory structure must match expected for scripts to run. 
	Pairs of fastq files (must be unzipped) should be located in their own folder (named unique sample ID).
	The shared folder contains the reference genome and zipped programs to send out for jobs.
	Outputs will be transferred back to outputs on job completion.

<pre>
	project<br/>
	----input_fastq<br/>
		---sample1<br/>
		---sample2<br/>
		---shared<br/>
			----DmelRef.fasta.tgz<br/>
			----pipeline_software.tgz<br/>	
	----outputs<br/>
</pre>

 Steps 2-4 are implemented in split_n_run.sh.<br/>
 2. Run split.pl (on the submit machine) for each sample to split into blocks. 
    Takes n lines for each block and name of sample folders as input<br/>
	Usage:  perl split.pl ${n_lines} ${FOLDER}
 
 3. Prepare the workflow file (dag).<br/>
	Input is the submit file (sub), the name to write the dag to, and ref seq name (zipped)<br/>
	Usage: perl prepare_dag.pl bwa_stampy.sub bwa_stampy_${NOW}.dag DmelRef.fasta.tgz

	Output .dag file lists the different variables for each job that will be submitted. 
<pre>
JOB 0 bwa_stampy.sub
VARS 0 ref="DmelRef.fasta.tgz"
VARS 0 fastq1="13Jan22-1_EF5N_S73_L002/13Jan22-1_EF5N_S73_L002_R1_001_Block00000.fastq.gz"
VARS 0 fastq2="13Jan22-1_EF5N_S73_L002/13Jan22-1_EF5N_S73_L002_R2_001_Block00000.fastq.gz"
VARS 0 block_id="13Jan22-1_EF5N_S73_L002_Block00000"
</pre>

 4. Submit to queue.
condor_submit_dag bwa_stampy_${NOW}.dag	

 5. To monitor afer submission run (the --nobatch argument shows all your jobs, but w/o it only shows the dagman job as one job.)
 condor_q --nobatch 
