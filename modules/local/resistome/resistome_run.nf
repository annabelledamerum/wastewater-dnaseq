process RESISTOME_RUN {
    tag "$meta.id"
    label 'process_high'

    input:
    tuple val(meta), path(bam)
    path(amr_fasta)
    path(amr_annotation)

    output:
    tuple val(meta), path("*resistome*.tsv"), emit: resistome_tsv
    path("*gene.tsv"), emit: gene_resistome_counts
    path("*group.tsv"), emit: group_resistome_counts
    path("*mechanism.tsv"), emit: mechanism_resistome_counts
    path("*class.tsv"), emit: class_resistome_counts

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
        -t ${params.resistome_threshold}

    rm ${prefix}.sam
    """
}
