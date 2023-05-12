process QIIME_TAXMERGE {
    label 'process_low'
    
    container 'quay.io/qiime2/core:2023.2'
    
    input:
    path(taxonomy)

    output:
    path('allsamples_taxonomylist.tsv'), emit: taxonomy

    script:
    """
    for i in $taxonomy
    do
        path=\$(realpath \${i})
        echo \$path
    done > taxonomy_files.tsv

    qiime_taxmerge.py -t taxonomy_files.tsv  
    """
}
