process RESISTOME_RUN {
    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(bam)
    path(amr_fasta)
    path(amr_annotation)

    output:
    tuple val(meta), path("*resistome*.tsv"), emit: resistome_tsv
    path("*.gene.tsv"), emit: resistome_counts

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    samtools view -h ${bam} > ${prefix}.sam
    
    resistome -ref_fp ${amr_fasta} \
        -annot_fp ${amr_annotation} \
        -sam_fp ${prefix}.sam \
        -gene_fp ${prefix}.resistome.gene.tsv \
        -group_fp ${prefix}.resistome.group.tsv \
        -mech_fp ${prefix}.resistome.mechanism.tsv \
        -class_fp ${prefix}.resistome.class.tsv \
        -type_fp ${prefix}.resistome.type.tsv \
        -t ${params.threshold}

    rm ${prefix}.sam
    """
}
