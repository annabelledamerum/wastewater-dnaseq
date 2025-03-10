process RGI_BWT {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::rgi=5.1.0"
    container 'quay.io/biocontainers/rgi:6.0.3--pyha8f3691_0'
    
    input: 
    tuple val(meta), path(reads)

    output:

    path "versions.yml"                      , emit: versions  


    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def reads_args = "-1 ${reads[0]} -2 ${reads[1]}"
    def args = task.ext.args ?: ''



    """
    rgi load \
        -i 

    rgi bwt \
        $reads_args \
        --output_file $prefix \
        -n "${task.cpus}" \
        $args \
        --clean --local 

    """
}