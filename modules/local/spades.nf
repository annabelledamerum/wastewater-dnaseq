process SPADES {
    tag "$meta.id"
    label 'process_high_memory'

    conda "bioconda::spades=3.15.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/spades:3.15.3--h95f258a_0' :
        'quay.io/biocontainers/spades:3.15.5--h95f258a_1' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*scaffolds.fasta"), emit: assembly
    tuple val(meta), path("*.gfa")           , emit: graph
    tuple val(meta), path("*.log")           , emit: log                             
    path "versions.yml"                      , emit: versions  

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def maxmem = task.memory.toGiga()
    def reads_args = "-1 ${reads[0]} -2 ${reads[1]}"
    def args = task.ext.args ?: ''
    """
    spades.py \
        --threads "${task.cpus}" \
        --memory $maxmem \
        $reads_args \
        -o $prefix \
        $args
    mv ${prefix}/scaffolds.fasta ${prefix}_scaffolds.fasta
    mv ${prefix}/assembly_graph_with_scaffolds.gfa ${prefix}_assembly_graph_with_scaffolds.gfa
    mv ${prefix}/spades.log ${prefix}_spades.log
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        spades: \$(spades.py --version 2>&1 | sed 's/^.*SPAdes genome assembler v//; s/ .*\$//')
    END_VERSIONS
    """
}