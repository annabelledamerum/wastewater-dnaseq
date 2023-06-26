process QIIME_BARPLOT {
    label 'process_medium'
    
    container 'quay.io/qiime2/core:2023.2'
    
    input:
    path(qza)
    path(taxonomy)

    output:
    path('*exported_QIIME_barplot/*')   , emit: barplot_export
    path('*exported_QIIME_barplot/*.csv') , emit: barplot_composition
    path('allsamples_compbarplot.qzv')   
    path "versions.yml"                        , emit: versions
    

    script:   
 
    """
    qiime taxa barplot --i-table $qza --i-taxonomy $taxonomy --o-visualization allsamples_compbarplot.qzv
    qiime tools export --input-path allsamples_compbarplot.qzv --output-path allsamples_exported_QIIME_barplot
    
    array=( \$( seq 1 7) )

    for i in \${array[@]}
    do
        qiimebarplot_tomultiqc.py -d allsamples_exported_QIIME_barplot/level-\$i.csv -l \$i
    done
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qiime: \$(qiime --version | sed '2,2d' | sed 's/q2cli version //g')
    END_VERSIONS
    """
}
