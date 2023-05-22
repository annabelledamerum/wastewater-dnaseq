process QIIME_DIVERSITYCORE {
    label 'process_medium'
   
    container 'quay.io/qiime2/core:2023.2'
     
    input:
    path(qza)
    path(aligned_read_totals)
    path(group_metadata)

    output:
    path('allsamples_diversity_core/*_vector.qza')         , emit: vector

    script:   
    """
    low_read_filter.py -q "$qza" -r $aligned_read_totals
    
    qiime feature-table merge --i-tables \$( < qza_lowqualityfiltered.txt) --o-merged-table allsamples_mergedqiime.qza

    qiime diversity core-metrics --i-table allsamples_mergedqiime.qza --p-sampling-depth \$( < readcount_maxsubset.txt ) --m-metadata-file $group_metadata --output-dir allsamples_diversity_core --p-n-jobs ${task.cpus}  
    """
}
