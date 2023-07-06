process SOURMASH_MERGEREADCOUNT {
    label 'process_low'

    conda "bioconda::biom-format=2.1.7=py27_0"
    container 'quay.io/biocontainers/biom-format:2.1.7--py27_0'

    input:
    path( fq_readcount )

    output:
    path("allsamples_totalreads.csv"), emit:allsamples_totalreads

    script:
    """
    sourmash_readcountmerge.py -r "$fq_readcount"
    """
}

