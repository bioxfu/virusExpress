configfile: "config.yaml"

rule all:
	input:
		expand('index/{viral}.fasta.1.ht2', viral=config['viral']),
		expand('bam/{sample}.bam', sample=config['samples']),
		expand('bam/{sample}.bam.bai', sample=config['samples']),
		expand('count/{sample}.cnt', sample=config['samples']),
		'table/virus_expression_RPKM.tsv'

rule build_index:
	input:
		'index/{viral}.fasta'
	output:
		'index/{viral}.fasta.1.ht2'
	params:
		conda = config['conda_path']
	shell:
		'{params.conda}/hisat2-build {input} {input}'

rule hisat2_PE:
	input:
		r1 = config['path']+'/clean/{sample}_R1_paired.fastq.gz',
		r2 = config['path']+'/clean/{sample}_R2_paired.fastq.gz'
	output:
		bam = 'bam/{sample}.bam'
	params:
		prefix = 'bam/{sample}',
		cpu = config['cpu'],
		index = 'index/'+config['viral']+'.fasta',
		strandness_hisat2 = config['strandness_hisat2'],
		conda = config['conda_path']		
	shell:
		"{params.conda}/hisat2 --rna-strandness {params.strandness_hisat2} -p {params.cpu} --dta -x {params.index} -1 {input.r1} -2 {input.r2} |samtools view -Shub -F 4|samtools sort - -T {params.prefix} -o {output.bam}"

rule bam_idx:
	input:
		bam = 'bam/{sample}.bam'
	output:
		bai = 'bam/{sample}.bam.bai'
	params:
		conda = config['conda_path']
	shell:
		'{params.conda}/samtools index {input.bam} {output.bai}'

rule bam_count:
	input:
		bam = 'bam/{sample}.bam',
		bai = 'bam/{sample}.bam.bai'
	output:
		'count/{sample}.cnt'
	params:
		conda = config['conda_path']
	shell:
		"{params.conda}/samtools idxstats {input.bam}|grep -v '*'|cut -f1-3 > {output}"

rule RPKM:
	input:
		bamstat = config['path']+'/stat/bamqc_stat.tsv',
		['count/{sample}.cnt'.format(sample=x) for x in config['samples']]
	output:
		'table/virus_expression_RPKM.tsv'
	params:
		Rscript = config['Rscript_path']
	shell:
		"{params.Rscript} script/RPKM.R {input.bamstat}"
