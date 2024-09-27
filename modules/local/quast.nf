process QUAST {
    tag "$meta.id"

    conda "bioconda::quast=5.0.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/quast:5.0.2--py37pl526hb5aa323_2' :
        'biocontainers/quast:5.0.2--py37pl526hb5aa323_2' }"

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("*report.tsv")    , emit: report
    path  "versions.yml"                    , emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    if (params.spades_mode == '--meta')
    """
    metaquast.py \
        --threads ${task.cpus} \
        -rna-finding --max-ref-number 0 \
        -o ${prefix} \
        $assembly
    mv ${prefix}/report.tsv ${prefix}_report.tsv
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaquast: \$(metaquast.py --version | sed "s/QUAST v//; s/ (MetaQUAST mode)//")
    END_VERSIONS
    """
    else
    """
    quast.py \
        --threads ${task.cpus} \
        -r  \
        -o ${prefix} \
        $assembly
    mv ${prefix}/report.tsv ${prefix}_report.tsv
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaquast: \$(metaquast.py --version | sed "s/QUAST v//; s/ (MetaQUAST mode)//")
    END_VERSIONS
    """


}