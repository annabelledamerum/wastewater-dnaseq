process QIIME_TAXMERGE {
    label 'process_low'
    
    container 'quay.io/qiime2/core:2023.2'
    
    input:
    path(taxonomy)

    output:
    path('allsamples_qiime_taxonomy.qza'), emit: merged_taxonomy

    script:
    """
    qiime_taxmerge.py -t $taxonomy 

    qiime tools import --input-path allsamples_taxonomylist.tsv --type 'FeatureData[Taxonomy]' --input-format TSVTaxonomyFormat --output-path allsamples_qiime_taxonomy.qza 
    """
}
