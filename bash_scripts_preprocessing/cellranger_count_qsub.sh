maindir="~/MiSeq/SE7267"
for i in $(cat barcodeAssociationTable.csv | sed "1 d"); 
do 
	id=$(echo $i | cut -d"," -f2) 
	folder=$(echo $i | cut -d"," -f1)
	sample=$(echo $(basename ${maindir})_${folder:3:7})
	fastq=$(echo ${maindir}/${folder}*)
	echo "
	cd cellranger_count_GRCh38-mm10
	cellranger count --include-introns --id=${id} --fastqs=$fastq --sample=${sample} --transcriptome=cellranger/refdata-gex-GRCh38-and-mm10-2020-A
	" | qsub -l h_vmem=16G -N count_$folder -o ~/logs/cellranger -j y
done