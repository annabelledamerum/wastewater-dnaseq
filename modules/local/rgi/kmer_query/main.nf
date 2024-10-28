process RGI_KMER_QUERY {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::rgi=5.1.0"
    container 'quay.io/biocontainers/rgi:6.0.3--pyha8f3691_0'
    
    input: 
    tuple val(meta), path(reads)

    output:


    script:
    """


    """
}