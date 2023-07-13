process SOURMASH_MERGEREADCOUNT {
    label 'process_low'

    input:
    path readcounts 

    output:
    path "allsamples_totalreads.csv", emit:allsamples_totalreads

    script:
    """
    sourmash_readcountmerge.py $readcounts
    """
}

