# Bulk_RNA-seq_workflow
A bulk RNA-seq pipeline to trim the reads with __fastp__, align the trimmmed reads with __STAR__, and quantify the expression profiles with __RSEM__.  
This is written in shell script.    

## How to run
__*1. Configure the environment for the pipeline*__  
Please see `env_config_for_rnaseq.sh` and `rnaseq_env.yml`.  
Tip: Remember to activate the environment by "conda activate rnaseq".
<br>
__*2. Create STAR genome and RSEM genome index*__   
Before running the pipeline, the STAR genome and RSEM genome index can be created by `create_index.sh`.  
<br>
__*3. Simply Run by changing the task.sh file*__  
Please see the pipeline at `rna_seq_analysis_pipeline.sh`.  
Example command to run the pipeline: `task.sh`.
  
