process MAXBIN2 {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::maxbin2=2.2.7"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/maxbin2:2.2.7--he1b5a44_2' :
        'quay.io/biocontainers/maxbin2:2.2.7--he1b5a44_2' }"

    input:
    tuple val(meta), path(contigs)
    path(depth)

    output:
    tuple val(meta), path("*.fasta")   , emit: binned_fastas
    tuple val(meta), path("*.summary") , emit: summary
    tuple val(meta), path("*.log")     , emit: log
    tuple val(meta), path("*.marker")  , emit: marker_counts
    tuple val(meta), path("*.noclass") , emit: unbinned_fasta
    tuple val(meta), path("*.tooshort"), emit: tooshort_fasta
    tuple val(meta), path("*_bin.tar") , emit: marker_bins , optional: true
    tuple val(meta), path("*_gene.tar"), emit: marker_genes, optional: true
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    cut -f1,3 $depth > maxbin2_abund.txt
    mkdir input/ && mv $contigs input/
    mkdir ${prefix}
    run_MaxBin.pl \\
        -contig input/$contigs \\
        -abund maxbin2_abund.txt \\
        -thread $task.cpus \\
        $args \\
        -out ${prefix}/${prefix}_maxbin2

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        maxbin2: \$( run_MaxBin.pl -v | head -n 1 | sed 's/MaxBin //' )
    END_VERSIONS
    """
}