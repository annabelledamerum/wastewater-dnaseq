process QIIME_DIVERSITYCORE {
    label 'process_medium'
   
    container 'quay.io/qiime2/core:2023.2'
     
    input:
    path(qza)
    path(readcount_maxsubset)
    path(filtered_metadata)

    output:
    path('diversity_core/*_vector.qza')         , emit: vector
    path('diversity_core/*_distance_matrix.qza'), emit: distance
    path("diversity_core/*.qzv")                , emit: qzv

    script:   
    """
    qiime diversity core-metrics \
        --i-table $qza \
        --p-sampling-depth \$( < $readcount_maxsubset ) \
        --m-metadata-file $filtered_metadata \
        --output-dir diversity_core \
        --p-n-jobs ${task.cpus} 
    """
}
