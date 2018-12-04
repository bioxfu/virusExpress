configfile: "config.yaml"

rule all:
	input:
		expand('index/{viral}.fasta.1.ht2', viral=config['viral']),
		expand('bam/{sample}.bam', sample=config['samples']),
		expand('bam/{sample}.bam.bai', sample=config['samples']),
		expand('fwd/{sample}.fwd.bam', sample=config['samples']),
		expand('fwd/{sample}.fwd.bam.bai', sample=config['samples']),
		expand('rev/{sample}.rev.bam', sample=config['samples']),
		expand('rev/{sample}.rev.bam.bai', sample=config['samples']),
		expand('fwd/{sample}.fwd.cov', sample=config['samples']),
		expand('rev/{sample}.rev.cov', sample=config['samples']),
		expand('track/{sample}.expr_track', sample=config['samples']),
		expand('count/{sample}.cnt', sample=config['samples']),
		expand('fwd/{sample}.fwd.cnt', sample=config['samples']),
		expand('rev/{sample}.rev.cnt', sample=config['samples']),
		'table/virus_expression_RPM.tsv',
		'table/virus_expression_RPM_fwd.tsv',
		'table/virus_expression_RPM_rev.tsv',

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
		"{params.conda}/hisat2 --rna-strandness {params.strandness_hisat2} -p {params.cpu} --dta -x {params.index} -1 {input.r1} -2 {input.r2} |{params.conda}/samtools view -Shub -F 4|{params.conda}/samtools sort - -T {params.prefix} -o {output.bam}"

rule bam_idx:
	input:
		bam = 'bam/{sample}.bam'
	output:
		bai = 'bam/{sample}.bam.bai'
	params:
		conda = config['conda_path']
	shell:
		'{params.conda}/samtools index {input.bam} {output.bai}'

rule bam_fwd_bam:
	input:
		bam = 'bam/{sample}.bam'
	output:
		bam = 'fwd/{sample}.fwd.bam',
		bai = 'fwd/{sample}.fwd.bam.bai'	
	params:
		conda = config['conda_path']
	shell:
		'{params.conda}/samtools view -hub -F 16 {input.bam} > {output.bam}; {params.conda}/samtools index {output.bam} {output.bai}'

rule bam_rev_bam:
	input:
		bam = 'bam/{sample}.bam'
	output:
		bam = 'rev/{sample}.rev.bam',
		bai = 'rev/{sample}.rev.bam.bai'
	params:
		conda = config['conda_path']
	shell:
		'{params.conda}/samtools view -hub -f 16 {input.bam} > {output.bam}; {params.conda}/samtools index {output.bam} {output.bai}'

rule bam_fwd_cov:
	input:
		bam = 'bam/{sample}.bam'
	output:
		cov = 'fwd/{sample}.fwd.cov'
	params:
		conda = config['conda_path']
	shell:
		'{params.conda}/samtools view -hub -F 16 {input.bam}|samtools depth -d 8000 - > {output.cov}'

rule bam_rev_cov:
	input:
		bam = 'bam/{sample}.bam'
	output:
		cov = 'fwd/{sample}.rev.cov'
	params:
		conda = config['conda_path']
	shell:
		'{params.conda}/samtools view -hub -f 16 {input.bam}|samtools depth -d 8000 - > {output.cov}'

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

rule bam_count_fwd:
	input:
		bam = 'fwd/{sample}.fwd.bam',
		bai = 'fwd/{sample}.fwd.bam.bai'
	output:
		'fwd/{sample}.fwd.cnt'
	params:
		conda = config['conda_path']
	shell:
		"{params.conda}/samtools idxstats {input.bam}|grep -v '*'|cut -f1-3 > {output}"

rule bam_count_rev:
	input:
		bam = 'rev/{sample}.rev.bam',
		bai = 'rev/{sample}.rev.bam.bai'
	output:
		'rev/{sample}.rev.cnt'
	params:
		conda = config['conda_path']
	shell:
		"{params.conda}/samtools idxstats {input.bam}|grep -v '*'|cut -f1-3 > {output}"

rule RPKM:
	input:
		['count/{sample}.cnt'.format(sample=x) for x in config['samples']]
	output:
		'table/virus_expression_RPM.tsv'
	params:
		bamstat = config['path']+'/stat/bamqc_stat.tsv',
		Rscript = config['Rscript_path']
	shell:
		"{params.Rscript} script/RPKM.R {params.bamstat}"

rule RPKM_fwd:
	input:
		['fwd/{sample}.fwd.cnt'.format(sample=x) for x in config['samples']]
	output:
		'table/virus_expression_RPM_fwd.tsv'
	params:
		bamstat = config['path']+'/stat/bamqc_stat.tsv',
		Rscript = config['Rscript_path']
	shell:
		"{params.Rscript} script/RPKM_fwd.R {params.bamstat}"

rule RPKM_rev:
	input:
		['rev/{sample}.rev.cnt'.format(sample=x) for x in config['samples']]
	output:
		'table/virus_expression_RPM_rev.tsv'
	params:
		bamstat = config['path']+'/stat/bamqc_stat.tsv',
		Rscript = config['Rscript_path']
	shell:
		"{params.Rscript} script/RPKM_rev.R {params.bamstat}"

rule expr_track:
	input:
		fwd = 'fwd/{sample}.fwd.cov',
		rev = 'rev/{sample}.rev.cov'
	output:
		track = 'track/{sample}.expr_track'
	params:
		conda = config['conda_path']
	shell:
		' python script/cal_expr_track.py {input.fwd} {input.rev} {output.track}'
