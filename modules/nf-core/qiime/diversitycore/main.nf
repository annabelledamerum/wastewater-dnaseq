process QIIME_DIVERSITYCORE {
    label 'process_low'
   
    container 'quay.io/qiime2/core:2023.2'
     
    input:
    path(qza)
    path(readcount_maxsubset)
    path(filtered_metadata)

    output:
    path('diversity_core/*_vector.qza')         , emit: vector
    path('diversity_core/*_distance_matrix.qza'), emit: distance
    path("diversity_core/*.qzv")                , emit: qzv
    path "versions.yml", emit: versions

    script:   
    """
    qiime diversity core-metrics \
        --i-table $qza \
        --p-sampling-depth \$( < $readcount_maxsubset ) \
        --m-metadata-file $filtered_metadata \
        --output-dir diversity_core \
        --p-n-jobs ${task.cpus}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qiime: \$(qiime --version | sed '2,2d' | sed 's/q2cli version //g')
    END_VERSIONS
    """
}
