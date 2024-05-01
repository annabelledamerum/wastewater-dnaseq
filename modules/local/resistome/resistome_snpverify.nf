process RESISTOME_SNPVERIFY {
    tag "$meta.id"
    label 'process_high'
    errorStrategy = { task.exitStatus in [1,143,137,104,134,139,Integer.MAX_VALUE] ? 'retry' : 'finish' }
    maxRetries = 2

    input:
    tuple val(meta), path(bam)
    path(gene_count_matrix)
    path(snp_config)
    path(snp_verify)

    output:
    path("*SNP_confirmed_gene.tsv"), emit: snp_counts

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    # change name to stay consistent with count matrix name, but only if the names don't match
    if [ "$bam" != "${prefix}.bam" ]; then
        mv $bam ${prefix}.bam
    fi

    SNP_Verification.py -c $snp_config -t $task.cpus -a true -i ${prefix}.bam -o ${prefix}.AMR_SNPs --count_matrix ${gene_count_matrix}

    cut -d ',' -f `awk -v RS=',' "/${prefix}/{print NR; exit}" ${prefix}.AMR_SNPs${gene_count_matrix}` ${prefix}.AMR_SNPs${gene_count_matrix} > ${prefix}.AMR_SNP_count_col

    cut -d ',' -f 1 ${prefix}.AMR_SNPs${gene_count_matrix} > gene_accession_labels

    paste gene_accession_labels ${prefix}.AMR_SNP_count_col > ${prefix}.SNP_confirmed_gene.tsv
    """
}
