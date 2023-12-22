local_path=$(cd `dirname $0` && pwd)
# Download miniconda
# wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
# Build the conda env rnaseq from rnaseq_env.yml
conda env create -f $local_path/rnaseq_env.yml
conda activate rnaseq

#### Or:
#### Download the tools step by step ######
# conda config --add channels defaults
# conda config --add channels bioconda
# conda config --add channels conda-forge

# conda create -n rnaseq rsem=1.3.3
# conda activate rnaseq
# conda install bwa=0.7.17 
# conda install star=2.7.11a
# conda install pigz=2.8
# conda install sra-tools=3.0.7 
# conda install fastp=0.23.4