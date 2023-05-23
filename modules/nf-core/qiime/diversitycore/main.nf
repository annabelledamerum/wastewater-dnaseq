process QIIME_DIVERSITYCORE {
    label 'process_medium'
   
    container 'quay.io/qiime2/core:2023.2'
     
    input:
    path(qza)
    path(aligned_read_totals)
    path(group_metadata)

    output:
    path('allsamples_diversity_core/*_vector.qza')         , emit: vector
    path('allsamples_diversity_core/*_distance_matrix.qza'), emit: distance
    path('filtered_metadata.tsv')                          , emit: filtered_metadata
    path('group_list.txt')                                 , emit: group_list

    script:   
    """
    low_read_filter.py -q "$qza" -r $aligned_read_totals

    metadata_pairwise.r $group_metadata
    
    sed -i 's/"//g' filtered_metadata.tsv
    
    qiime feature-table merge --i-tables \$( < qza_lowqualityfiltered.txt) --o-merged-table allsamples_mergedqiime.qza

    qiime diversity core-metrics --i-table allsamples_mergedqiime.qza --p-sampling-depth \$( < readcount_maxsubset.txt ) --m-metadata-file filtered_metadata.tsv --output-dir allsamples_diversity_core --p-n-jobs ${task.cpus}  
    """
}
