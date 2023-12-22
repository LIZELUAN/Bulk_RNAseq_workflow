# bulk_RNA-seq_workflow
a bulk RNA-seq pipeline to trim the reads with __fastp__, align the trimmmed reads with __STAR__, and quantify the expression profiles with __RSEM__.  
This is written in shell script    

# How to run
1. Configure the environment for the pipeline  
Please see __env_config_for_rnaseq.sh__ and __rnaseq_env.yml__.  
  
2. Create STAR genome and RSEM genome index  
Before running the pipeline, the STAR genome and RSEM genome index can be created by __create_index.sh__.

3. Run the task.sh  
The reproducible pipeline sh script is __rna_seq_analysis_pipeline.sh__.
Please see the example command to run the pipeline: __task.sh__.
