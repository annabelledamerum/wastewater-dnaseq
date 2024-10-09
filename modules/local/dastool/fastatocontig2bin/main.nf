process DASTOOL_FASTATOCONTIG2BIN {
    tag "$meta.id"
    label 'process_single'

    conda "bioconda::das_tool=1.1.6"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/das_tool:1.1.6--r42hdfd78af_0' :
        'biocontainers/das_tool:1.1.6--r42hdfd78af_0' }"

    input:
    tuple val(meta), path(fasta)
    val(extension)

    output:
    tuple val(meta), path("*.tsv"), emit: fastatocontig2bin
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def file_extension = extension ? extension : "fasta"
    def clean_fasta = fasta.toString() - ".gz"
    """
    Fasta_to_Contig2Bin.sh \\
        $args \\
        -i . \\
        -e $file_extension \\
        > ${prefix}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dastool: \$( DAS_Tool --version 2>&1 | grep "DAS Tool" | sed 's/DAS Tool //' )
    END_VERSIONS
    """
}