process QIIME_QIIME {
    label 'process_medium'
    
    container 'quay.io/qiime2/core:2023.2'
    
    input:
    tuple val(meta), path(profile)
    path(taxonomy)

    output:
    path('*.csv')   , emit: composition
    path "versions.yml"                        , emit: versions
    

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    qiime tools import --input-path $profile --type 'FeatureTable[Frequency]' --input-format BIOMV100Format --output-path ${prefix}_qiime_relfreq_table.qza
    qiime tools import --input-path $taxonomy --type 'FeatureData[Taxonomy]' --input-format TSVTaxonomyFormat --output-path ${prefix}_qiime_taxonomy.qza

    qiime taxa barplot --i-table ${prefix}_qiime_relfreq_table.qza --i-taxonomy ${prefix}_qiime_taxonomy.qza --o-visualization ${prefix}_visualization.qzv
    qiime tools export --input-path ${prefix}_visualization.qzv --output-path ${prefix}_exported_QIIME_barplot
    
    array=( \$( seq 1 7) )

    for i in \${array[@]}
    do
        mv ${prefix}_exported_QIIME_barplot/level-\$i.csv ${prefix}_level-\$i.csv
    done 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qiime: \$(qiime --version | sed '2,2d' | sed 's/q2cli version //g')
    END_VERSIONS
    """
}
