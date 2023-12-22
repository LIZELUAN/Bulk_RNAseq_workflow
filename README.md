# bulk_RNA-seq_workflow
a bulk RNA-seq pipeline to trim the reads with fastp, align the trimmmed reads with STAR, and quantify the expression profiles with rsem.  
This is written in shell script    

# How to run
1. Configure the environment for the pipeline
Please see env_config_for_rnaseq.sh and rnaseq_env.yml.  
  
2. Create STAR genome and RSEM genome index
Before running the pipeline, the STAR genome and RSEM genome index can be created by create_index.sh.

3. Run the task.sh
The reproducible pipeline sh script is rna_seq_analysis_pipeline.sh.
Example command to run the pipeline: task.sh.
