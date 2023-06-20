process QIIME_IMPORT {
    label 'process_medium'
    
    container 'quay.io/qiime2/core:2023.2'
    
    input:
    tuple val(meta), path(rel_profile), path(abs_profile)

    output:
    path('*relfreq_table.qza')   , emit: relabun_merged_qza
    path('*absfreq_table.qza')   , emit: absabun_merged_qza
    path "versions.yml"                        , emit: versions
    

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    qiime tools import --input-path $rel_profile --type 'FeatureTable[Frequency]' --input-format BIOMV100Format --output-path ${prefix}_qiime_relfreq_table.qza
    qiime tools import --input-path $abs_profile --type 'FeatureTable[Frequency]' --input-format BIOMV100Format --output-path ${prefix}_qiime_absfreq_table.qza
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qiime: \$(qiime --version | sed '2,2d' | sed 's/q2cli version //g')
    END_VERSIONS
    """
}
