process QIIME_TAXMERGE {
    label 'process_low'
    
    container 'quay.io/qiime2/core:2023.2'
    
    input:
    path(taxonomy)

    output:
    path('allsamples_qiime_taxonomy.qza'), emit: taxonomy

    script:
    """
    for i in $taxonomy
    do
        path=\$(realpath \${i})
        echo \$path
    done > taxonomy_files.tsv

    qiime_taxmerge.py -t taxonomy_files.tsv 

    qiime tools import --input-path allsamples_taxonomylist.tsv --type 'FeatureData[Taxonomy]' --input-format TSVTaxonomyFormat --output-path allsamples_qiime_taxonomy.qza 
    """
}
