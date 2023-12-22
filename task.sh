local_path=$(cd `dirname $0` && pwd)
chmod +x $local_path/rna_seq_analysis_pipeline.sh
nohup $local_path/rna_seq_analysis_pipeline.sh --sample_list $local_path/fq/SRR_Acc_List.txt --fastq_gz_Dir $local_path/fq/ --suffix fastq.gz --star_genome $local_path/star_genome/ --rsem_genome $local_path/rsem_genome/rsem --nThread_f 5 --nThread_s 5 --nThread_r 5 --nSample_perRun 3 >$local_path/nohup.out 2>&1 &
