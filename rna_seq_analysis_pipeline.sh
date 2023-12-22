#!/bin/bash
# AUTHOR: Zeluan LI
# DATE: 2023.11
manual="
Description: a shell pipeline for fastp trimming, STAR alignment, and rsem quantification of multiple samples
Usage: ./rna_seq_analysis_pipeline.sh [options]         
Options:
	-a, --outDir             directory for output files, bydefault is the directory of the script
*	-b, --sample_list        sample id list, one sample id a line, for example:
						 _____________
						|             |
						| SRR13155442 |
						| SRR13155443 |	
						|_____________|
		
*	-c, --fastq_gz_Dir       directory of fq.gz files
	-d, --suffix             suffix of fq.gz files, can be fq.gz or fastq.gz, bydefault=fq.gz
*	-e, --star_genome        directory of star ref genome 
*	-f, --rsem_genome        format: path_to_rsem_genome/prefix_of_filename
	-g, --nThread_f          number of threads for fastp, bydefault=6
	-h, --nThread_s          number of threads for star, bydefault=6 
	-i, --nThread_r          number of threads for rsem, bydefault=6
	-j, --nSample_perRun     number of samples processed simultaneously per run, bydefault=1
	-k, --fastp              Path to fastp, bydefault="fastp"
	-l, --star               Path to STAR, bydefault="STAR"
	-m, --rsemcal            Path to rsem-calculate-expression, bydefault="rsem-calculate-expression"
"

if [[ $# -lt 8 ]]; then
	echo -e "The number of input parameters is insufficient. Please see the manual below.\n ${manual}" >&2
	exit 1
fi

output_path=$(cd `dirname $0` && pwd)
suffix="fq.gz"
n_thread_f=6
n_thread_s=6
n_thread_r=6
n_sample=1
fastP="fastp"
staR="STAR"
rsemC="rsem-calculate-expression"
#
# Get options
OPTSTRING1="a:b:c:d:e:f:g:h:i:j:k:l:m:"
OPTSTRING="outDir:,sample_list:,fastq_gz_Dir:,suffix:,star_genome:,rsem_genome:,nThread_f:,nThread_s:,nThread_r:,nSample_perRun:,fastp:,star:,rsemcal:" 
set -- $(getopt -o ${OPTSTRING1} --long ${OPTSTRING} -- "$@")
echo "$@"
while true
do
case "$1" in
	'-a' | '--outDir')
		output_path=$(echo $2 | sed "s/'//g" | sed 's/\/$//g')
		echo "output_path: ${output_path}"
		shift 2;;
	'-b' | '--sample_list')
		sample_list=$(echo $2 | sed "s/'//g")
		echo "sample_list: ${sample_list}"
		shift 2;;
	'-c' | '--fastq_gz_Dir')
		fastq_gz_dir=$(echo $2 | sed "s/'//g" | sed 's/\/$//g')
		echo "fastq_gz_dir: ${fastq_gz_dir}"
		shift 2;;
	'-d' | '--suffix')
		suffix=$(echo $2 | sed "s/'//g")
		shift 2;;
	'-e' | '--star_genome')
		star_genome=$(echo $2 | sed "s/'//g" | sed 's/\/$//g')
		echo "star_genome: ${star_genome}"
		shift 2;;
	'-f' | '--rsem_genome')
		rsem_genome=$(echo $2 | sed "s/'//g")
		echo "rsem_genome: ${rsem_genome}"
		shift 2;;
	'-g' | '--nThread_f')
		n_thread_f=$(echo $2 | sed "s/'//g")
		echo "n_thread_f: ${n_thread_f}"
		shift 2;;
	'-h' | '--nThread_s')
		n_thread_s=$(echo $2 | sed "s/'//g")
		echo "n_thread_s: ${n_thread_s}"
		shift 2;;
	'-i' | '--nThread_r')
		n_thread_r=$(echo $2 | sed "s/'//g")
		echo "n_thread_r: ${n_thread_r}"
		shift 2;;
	'-j' | '--nSample_perRun')
		n_sample=$(echo $2 | sed "s/'//g")
		echo "nSample_perRun: ${n_sample}"
		shift 2;;
	'-k' | '--fastp')
		fastP=$(echo $2 | sed "s/'//g")
		shift 2;;
	'-l' | '--star')
		staR=$(echo $2 | sed "s/'//g")
		shift 2;;
	'-m' | '--rsemcal')
		rsemC=$(echo $2 | sed "s/'//g")
		shift 2;;
	'--')
		break;;
	*)
		echo -e "Error: Unknown option: $1. Please see the manual below.\n ${manual}" >&2
		exit 1;;
esac
done && \
# 
# Create output directories
mkdir -p ${output_path}/shes && \
mkdir -p ${output_path}/02clean && \
mkdir -p ${output_path}/03align_out && \
mkdir -p ${output_path}/04rsem_out && \
# 
# Create sh files for analysis
while read id
do
cat>${output_path}/shes/${id}.sh<<EOF
#!/bin/bash
# quality control
echo "=== fastp Trimming ===" && \
${fastP} \
-i ${fastq_gz_dir}/${id}_1.${suffix} -I ${fastq_gz_dir}/${id}_2.${suffix} \
-o ${output_path}/02clean/${id}_trim_1.${suffix} -O ${output_path}/02clean/${id}_trim_2.${suffix} \
-w ${n_thread_f} \
--html ${output_path}/02clean/${id}.html \
--json ${output_path}/02clean/${id}.json && \
# star alignment
echo "=== STAR Alignment ===" && \
${staR} --runThreadN ${n_thread_s} \
--genomeDir ${star_genome} \
--readFilesCommand zcat \
--readFilesIn ${output_path}/02clean/${id}_trim_1.${suffix} \
${output_path}/02clean/${id}_trim_2.${suffix} \
--outFileNamePrefix ${output_path}/03align_out/${id}_ \
--outSAMtype BAM SortedByCoordinate \
--outBAMsortingThreadN ${n_thread_s} \
--quantMode TranscriptomeSAM GeneCounts && \
# rsem quantification
echo "=== RSEM Quantification ===" && \
${rsemC} --paired-end --no-bam-output \
--alignments -p ${n_thread_r} \
-q ${output_path}/03align_out/${id}_Aligned.toTranscriptome.out.bam \
${rsem_genome} \
${output_path}/04rsem_out/${id}_rsem && \
echo "${id} finished."
EOF
 

done < ${sample_list} && \
#
# wirte the sample sh files list to the runsh file
for i in $(ls ${output_path}/shes/*.sh)
do
echo "${output_path}/shes/$(basename $i)" >> ${output_path}/cancer_run.sh
done && \
#
# Conduct the analysis
start_time=`date +%s`
tmp_fifofile="/tmp/$$.fifo"
mkfifo $tmp_fifofile && \
exec 6<>$tmp_fifofile && \
rm $tmp_fifofile && \
for ((i=0;i<${n_sample};i++));
do
echo
done >&6 && \
##
while read sh_file
do
read -u6  # Control the thread number
{
bash $sh_file
echo >&6
} >${sh_file}.log 2>&1 &
done < ${output_path}/cancer_run.sh && \
wait && \
end_time=`date +%s` && \
# Check the output
if [ $(find ${output_path}/04rsem_out/*_rsem.*.results | wc -l) -gt 0 ]
then
echo "Analysis finished!"
echo "Start time: ${start_time}"
echo "End time: ${end_time}"
else
echo "Analysis failed. There is no output in ${output_path}/04rsem_out."
fi

