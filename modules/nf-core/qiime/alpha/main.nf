process QIIME_ALPHA {
    label 'process_low'
    
    container 'quay.io/qiime2/core:2023.2'
    
    input:
    path(qza)

    output:
    path('*allsamples_alpha_export/alpha-diversity.tsv')   , emit: allsamplesalpha
    path('*alphachart_mqc.json'), emit: mqc_alpha
    

    script:   
    """
    qiime feature-table merge --i-tables $qza --o-merged-table allsamples_mergedqiime.qza 

    qiime diversity alpha --i-table allsamples_mergedqiime.qza --p-metric 'shannon' --o-alpha-diversity allsamples_alpha.qza
 
    qiime tools export --input-path allsamples_alpha.qza --output-path allsamples_alpha_export

    display_qiimealpha_mqc.py -a allsamples_alpha_export/alpha-diversity.tsv
    """
}
