process SAMTOOLS_COLLECT_STATS {
    tag "$meta.id"
    label 'process_single'

    conda "bioconda::samtools=1.16.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.16.1--h6899075_1' :
        'quay.io/biocontainers/samtools:1.16.1--h6899075_1' }"

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    tuple val(meta), path("*.stats"), emit: stats
    tuple val(meta), path("*.flagstat"), emit: stats
    tuple val(meta), path("*.idxstats"), emit: stats
    tuple val(meta), path("*.coverage.txt"), emit: coverage
    path "versions.yml", emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def ff = params.options.excludeFlags ? "--ff ${params.options.excludeFlags}" : ""
    def q = params.options.threshMapq ? "-q ${params.options.threshMapq}" : ""
    """
    samtools stats -@ ${task.cpus} ${bam} > ${prefix}_mkdup.bam.stats
    samtools flagstat -@ ${task.cpus} ${bam} > ${prefix}_mkdup.flagstat
    samtools idxstats -@ ${task.cpus} ${bam} > ${prefix}_mkdup.bam.idxstats
    samtools coverage -o ${prefix}.coverage.txt ${bam} --ff UNMAP,QCFAIL,DUP -q 30

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}