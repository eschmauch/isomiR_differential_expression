#!/bin/bash
#SBATCH -N 1                      # Number of nodes. You must always set -N 1 unless you receive special instruction from the system admin
#SBATCH -n 8                     # Number of CPUs. Equivalent to the -pe whole_nodes 1 option in SGE
#SBATCH --mail-type=END           # Type of email notification- BEGIN,END,FAIL,ALL. Equivalent to the -m option in SGE 
#SBATCH --mem-per-cpu=35G
#SBATCH --time=4-20:30:01

module load fastxtoolkit
module load fastqc

mkdir fastq
cp FASTQ_gz/*.gz fastq/
cd fastq
gzip -d *.gz
ls *.fastq > ../list_files
cd ../

mkdir adapt_fastqc
mkdir adapt_filt_fastqc
trim_qc(){
	line=$1
	var1=$(echo $line | cut -f1 -d.)
	fastx_clipper -a [ADAPTER SEQ] -i fastq/$line -o fastq/adapt_${line} -v -n -Q33
	rm fastq/$line 
	fastqc fastq/adapt_${line} -o adapt_fastqc/
	fastq_quality_filter -q 30 -p 90 -i fastq/adapt_${line} -o fastq/adapt_filt_${line} -v -Q33
	rm fastq/adapt_${line}
	fastqc fastq/adapt_filt_${line} -o adapt_filt_fastqc/
	var1=$(echo $line | cut -f1 -d.)
	fastq_to_fasta -i fastq/adapt_filt_${line} -o fastq/$var1.fa -v -Q33
	rm fastq/adapt_filt_${line}
}

while read line
do 
	trim_qc "$line" &
done < list_files

wait

echo "Job finished"


