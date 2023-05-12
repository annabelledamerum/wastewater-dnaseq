process QIIME_BARPLOT {
    label 'process_medium'
    
    container 'quay.io/qiime2/core:2023.2'
    
    input:
    path(qza)
    path(taxonomy)

    output:
    path('*exported_QIIME_barplot/*')   , emit: qiime_export
    path('*exported_QIIME_barplot/*.csv') , emit: composition
    path "versions.yml"                        , emit: versions
    

    script:   
 
    """
    qiime feature-table merge --i-tables $qza --o-merged-table allsamples_mergedqiime.qza 

    qiime tools import --input-path $taxonomy --type 'FeatureData[Taxonomy]' --input-format TSVTaxonomyFormat --output-path allsamples_qiime_taxonomy.qza

    qiime taxa barplot --i-table allsamples_mergedqiime.qza --i-taxonomy allsamples_qiime_taxonomy.qza --o-visualization allsamples_visualization.qzv
    qiime tools export --input-path allsamples_visualization.qzv --output-path allsamples_exported_QIIME_barplot
    
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
