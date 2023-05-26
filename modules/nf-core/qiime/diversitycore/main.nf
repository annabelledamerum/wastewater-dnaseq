process QIIME_DIVERSITYCORE {
    label 'process_medium'
   
    container 'quay.io/qiime2/core:2023.2'
     
    input:
    path(qza)
    path(readcount_maxsubset)
    path(group_metadata)

    output:
    path('allsamples_diversity_core/*_vector.qza')         , emit: vector
    path('allsamples_diversity_core/*_distance_matrix.qza'), emit: distance
    path('filtered_metadata.tsv')                          , emit: filtered_metadata
    path('group_list.txt')                                 , emit: group_list

    script:   
    """
    metadata_pairwise.r $group_metadata
    
    sed -i 's/"//g' filtered_metadata.tsv
    
    qiime diversity core-metrics --i-table $qza --p-sampling-depth \$( < $readcount_maxsubset ) --m-metadata-file filtered_metadata.tsv --output-dir allsamples_diversity_core --p-n-jobs ${task.cpus}  
    """
}
