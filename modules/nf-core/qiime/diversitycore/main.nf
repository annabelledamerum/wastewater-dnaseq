process QIIME_DIVERSITYCORE {
    label 'process_medium'
   
    container 'quay.io/qiime2/core:2023.2'
     
    input:
    path(qza)
    path(readcount_maxsubset)
    path(filtered_metadata)

    output:
    path('allsamples_diversity_core/*_vector.qza')         , emit: vector
    path('allsamples_diversity_core/*_distance_matrix.qza'), emit: distance

    script:   
    """
    qiime diversity core-metrics --i-table $qza --p-sampling-depth \$( < $readcount_maxsubset ) --m-metadata-file $filtered_metadata --output-dir allsamples_diversity_core --p-n-jobs ${task.cpus} 
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qiime: \$(qiime --version | sed '2,2d' | sed 's/q2cli version //g')
    END_VERSIONS

    """
}
