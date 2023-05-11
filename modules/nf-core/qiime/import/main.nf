process QIIME_IMPORT {
    label 'process_medium'
    
    container 'quay.io/qiime2/core:2023.2'
    
    input:
    tuple val(meta), path(profile)

    output:
    path('*.qza')   , emit: mergedbiom_qza
    path "versions.yml"                        , emit: versions
    

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    qiime tools import --input-path $profile --type 'FeatureTable[Frequency]' --input-format BIOMV100Format --output-path ${prefix}_qiime_relfreq_table.qza
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qiime: \$(qiime --version | sed '2,2d' | sed 's/q2cli version //g')
    END_VERSIONS
    """
}
