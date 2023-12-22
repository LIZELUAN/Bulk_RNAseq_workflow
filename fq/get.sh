local_path=$(cd `dirname $0` && pwd)
# TO download data from SRA
while read id
do 
prefetch -O $local_path/sra_file $id &
done < $local_path/SRR_Acc_List.txt && \
# prefetch -O sra_file --option-file SRR_Acc_List.txt
wait && \
echo "Sra files download finish." && \
# Put *.sra together in the directory sra
while read id
do
mv $local_path/sra_file/${id}/* $local_path/sra_file
done < $local_path/SRR_Acc_List.txt && \
#
while read id
do
rmdir $local_path/sra_file/$id
done < $local_path/SRR_Acc_List.txt && \
# decompress sra file into fq.gz file
while read id
do
echo "Process ${id}.sra" && \
fasterq-dump -3 -e 12 -O $local_path/ $local_path/sra_file/${id}.sra && \
pigz -p 12 $local_path/${id}_*.fastq
done < $local_path/SRR_Acc_List.txt && \

# remove sra files
rm -r $local_path/sra_file

