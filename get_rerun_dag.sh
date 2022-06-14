#!/bin/bash

# 2022-06-11 JCF

# On some CHTC nodes, stampy (or python 2) compilation fails and stampy doesn't run,  
#	resulting in failed jobs.  Generally this is only currently happening
#	when I submit many jobs at once. Last run 19/366 failed, so while I should
#	figure out what the OS? version issue is, this is small enough percentage 
#	to just rerun failed jobs for now.

# When stampy does run, it outputs progress to stderr, which is captured
#	in the .err files returned from the nodes (when it doesn't
#	many python input exceptions captured in the file, but not taking advantage
#	of that here.


#####################################################
Help()
{
# Display help
# Argument one is name for dag output
echo "Usage: ./get_rerun_dag.sh dag_file output_folder_location"

}


#####################################################

# Input 1 should be .dag file
FILE=$1
PREFIX=$( echo $FILE | sed 's/.dag//' )

OUTPUT_DIR=$2

# For all .err files in outputs, count the instances of "stampy: Done" (3 if success, 0 if not)
#	and take non successes forward into file
find ${OUTPUT_DIR} -maxdepth 1 -name "*.err" | \
	xargs grep -c "stampy: Done" | \
	grep ".err:0" | sed "s/.err.*.//" | sed 's/^.*_stampy_//' \
	> ${PREFIX}_failed_jobs.txt

# For the failed jobs, just find the lines for them in the original dag, and make 
#	a new dag rerun file
cat ${PREFIX}_failed_jobs.txt | xargs -n 1 -I % \
	grep -B 4 % ${FILE} > ${PREFIX}_rerun.dag
