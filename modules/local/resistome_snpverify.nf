process RESISTOME_SNPVERIFY {
    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(bam)
    path(gene_count_matrix)

    output:
    path("*SNP_confirmed_gene.tsv"), emit: snp_counts

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    # change name to stay consistent with count matrix name, but only if the names don't match
    if [ "$bam" != "${prefix}.bam" ]; then
        mv $bam ${prefix}.bam
    fi

    python3 ./AmrPlusPlus_SNP/SNP_Verification.py -c config.ini -t $task.cpus -a true -i ${prefix}.bam -o ${prefix}.AMR_SNPs --count_matrix ${gene_count_matrix}

    cut -d ',' -f `awk -v RS=',' "/${prefix}/{print NR; exit}" ${prefix}.AMR_SNPs${gene_count_matrix}` ${prefix}.AMR_SNPs${gene_count_matrix} > ${prefix}.AMR_SNP_count_col

    cut -d ',' -f 1 ${prefix}.AMR_SNPs${gene_count_matrix} > gene_accession_labels

    paste gene_accession_labels ${prefix}.AMR_SNP_count_col > ${prefix}.SNP_confirmed_gene.tsv
    """
}
