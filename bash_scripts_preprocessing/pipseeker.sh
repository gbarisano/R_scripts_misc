for i in $SCRATCH/pipseq/usftp21.novogene.com/01.RawData/*/; do 
	sbatch -J pipseeker -o $SCRATCH/pipseq/pip_%j.out -t 2-0 --mem 35G -c 8 --wrap="
	i=${1} #this is the directory where the fastq files are. Should correspond to the sample name.
	name=$(basename $i) #this becomes the sample name
	outdir=$SCRATCH/pipseq/pipseeker_out
	mkdir -p ${outdir}/${name}/raw_fastq_inputs

	forward_target=($i/*_1.fq.gz);
	reverse_target=($i/*_2.fq.gz);
	forward_link=$(echo $outdir/${name}/raw_fastq_inputs/$name"_R1.fastq.gz")
	reverse_link=$(echo $outdir/${name}/raw_fastq_inputs/$name"_R2.fastq.gz") 
	ln -s $forward_target $forward_link;
	ln -s $reverse_target $reverse_link;

	pipseeker=/home/groups/software/pipseeker/
	${pipseeker}/pipseeker-v3.3.0-linux/pipseeker full --chemistry v4 --threads 10 --fastq $outdir/${name}/raw_fastq_inputs/$name --star-index-path ${pipseeker}/mapping_references/pipseeker-gex-reference-GRCh38-2022.04 --output-path ${outdir}/${name}/${name}-results
	"
done