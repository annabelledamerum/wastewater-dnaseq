process MEGAHIT {
    tag "$meta.id"
    label 'process_high_memory'

    conda "bioconda::megahit=1.2.9"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/f2/f2cb827988dca7067ff8096c37cb20bc841c878013da52ad47a50865d54efe83/data' :
        'community.wave.seqera.io/library/megahit_pigz:87a590163e594224' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.contigs.fa")    , emit: assembly
    tuple val(meta), path("*.log")           , emit: log                             
    path "versions.yml"                      , emit: versions  

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def maxmem = params.max_memory.toBytes()
    def reads_args = "-1 ${reads[0]} -2 ${reads[1]}"
    def args = task.ext.args ?: ''
    """
    megahit \\
        $reads_args \\
        -t ${task.cpus} \\
        $args \\
        --out-prefix ${prefix}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        megahit: \$(echo \$(megahit -v 2>&1) | sed 's/MEGAHIT v//')
    END_VERSIONS
    """
}