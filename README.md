# Implementation of the Drosophila Genome Nexus style 2-step mapping.

 1. Directory structure must match expected for scripts to run. 
	Pairs of fastq files (must be unzipped) should be located in their own folder (named unique sample ID).
	The shared folder contains the reference genome and zipped programs to send out for jobs.
	Outputs will be transferred back to outputs on job completion.

	project<br/>
	----input_fastq<br/>
		---sample1<br/>
		---sample2<br/>
		----shared<br/>
			----DmelRef.fasta.tgz<br/>
			----pipeline_software.tgz<br/>	
	----outputs<br/>

 Steps 2-4 are implemented in split_n_run.sh.<br/>
 2. Run split.pl (on the submit machine) for each sample to split into blocks. 
    Takes n lines for each block and name of sample folders as input
	Usage:  perl split.pl ${n_lines} ${FOLDER}

3.




