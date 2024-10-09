process DASTOOL_DASTOOL {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::das_tool=1.1.6"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/das_tool:1.1.6--r42hdfd78af_0' :
        'quay.io/biocontainers/das_tool:1.1.6--r42hdfd78af_0' }"

    input:
    tuple val(meta), path(contigs)
    path(bins_maxbin)
    path(bins_metabat)

    output:
    tuple val(meta), path("*.log")                      , emit: log
    tuple val(meta), path("*_summary.tsv")              , optional: true, emit: summary
    tuple val(meta), path("*_DASTool_contig2bin.tsv")   , optional: true, emit: contig2bin
    tuple val(meta), path("*_DASTool_bins/*.fa")        , optional: true, emit: bins
    tuple val(meta), path("*.candidates.faa")           , optional: true, emit: fasta_proteins
    tuple val(meta), path("*.faa")                      , optional: true, emit: candidates_faa
    tuple val(meta), path("*.archaea.scg")              , optional: true, emit: fasta_archaea_scg
    tuple val(meta), path("*.bacteria.scg")             , optional: true, emit: fasta_bacteria_scg
    tuple val(meta), path("*.b6")                       , optional: true, emit: b6
    tuple val(meta), path("*.seqlength")                , optional: true, emit: seqlength
    path "versions.yml"                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def bin_list = "${bins_maxbin},${bins_metabat}"
    def search_engine = params.dastool_search_engine

    """
    DAS_Tool \\
        $args \\
        --search_engine $search_engine \\
        -t $task.cpus \\
        -i $bin_list \\
        -c $contigs \\
        -o $prefix

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dastool: \$( DAS_Tool --version 2>&1 | grep "DAS Tool" | sed 's/DAS Tool //' )
    END_VERSIONS
    """
}