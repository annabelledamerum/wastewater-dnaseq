process QIIME_METADATAFILTER {
   
    input:
    path( group_metadata ) 
    path( samples_filtered )

    output:
    path('filtered_metadata.tsv') , emit: filtered_metadata, optional: true
    path('ref_comp_metadata.tsv') , emit: ref_comp_metadata, optional: true
    stdout                          emit: min_total

    script:   
    """
    filter_metadata_find_min_counts.py -m $group_metadata -c $samples_filtered
    """
}
