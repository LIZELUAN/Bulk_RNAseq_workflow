local_path=$(cd `dirname $0` && pwd)

# create a dir
mkdir -p $local_path/rsem_genome

# rsem build index
rsem-prepare-reference --gtf $local_path/ref/gencode.v42.basic.annotation.gtf \
$local_path/ref/GRCh38.primary_assembly.genome.fa \
$local_path/rsem_genome/rsem && \
echo "finish!"
# STAR build index
STAR --runThreadN 6 \
--runMode genomeGenerate \
--genomeDir $local_path/star_genome \
--genomeFastaFiles $local_path/ref/GRCh38.primary_assembly.genome.fa \
--sjdbGTFfile $local_path/ref/gencode.v42.basic.annotation.gtf \
--sjdbOverhang 149 && \
echo "finish!"

