process METABAT2_METABAT2 {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::metabat2=2.15"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/metabat2:2.15--h986a166_1' :
        'quay.io/biocontainers/metabat2:2.15--h986a166_1' }"

    input:
    tuple val(meta), path(fasta)
    path(depth)

    output:
    tuple val(meta), path("*.tooShort")                       , optional:true, emit: tooshort
    tuple val(meta), path("*.lowDepth")                       , optional:true, emit: lowdepth
    tuple val(meta), path("*.unbinned")                       , optional:true, emit: unbinned
    tuple val(meta), path("*.tsv")                            , optional:true, emit: membership
    tuple val(meta), path("*[!lowDepth|tooShort|unbinned].fa"), optional:true, emit: binned_fastas
    path "versions.yml"                                                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args             = task.ext.args   ?: ''
    def prefix           = task.ext.prefix ?: "${meta.id}"
    """
    echo "input file fasta: ${fasta}"
    echo "input file depth: ${depth}"

    metabat2 \\
        $args \\
        -i $fasta \\
        -a $depth \\
        -t $task.cpus \\
        --saveCls \\
        -o ${prefix}_metabat2

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metabat2: \$( metabat2 --help 2>&1 | head -n 2 | tail -n 1| sed 's/.*\\:\\([0-9]*\\.[0-9]*\\).*/\\1/' )
    END_VERSIONS
    """
}