process PICARD_MARKDUPLICATES {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::picard=3.3.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/picard:3.3.0--hdfd78af_0' :
        'quay.io/biocontainers/picard:3.3.0--hdfd78af_0' }"

    input:
    tuple val(meta), path(bam)
    path(reference)

    output:
    tuple val(meta), path("*_mkdup.bam"), path("*_mkdup.bam.bai"), emit: mkdup_bam
    tuple val(meta), path("*_mkdup_metrics.txt")                 , emit: mkdup_metrics
    path  "versions.yml"                                         , emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    picard MarkDuplicates -Xmx${task.memory.giga}g \\
        -I ${bam} \\
        -O ${prefix}_mkdup.bam \\
        -M ${prefix}_mkdup_metrics.txt \\
        -R ${reference} \\
        --CREATE_INDEX true \\
        --ASSUME_SORT_ORDER coordinate \\
        --TMP_DIR ./tmp \\
            > ${prefix}_markduplicates.log 2>&1

    mv ${prefix}_mkdup.bai ${prefix}_mkdup.bam.bai

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        picard: \$(echo \$(picard MarkDuplicates --version 2>&1) | grep -o 'Version:.*' | cut -f2- -d:)
    END_VERSIONS
    """
}