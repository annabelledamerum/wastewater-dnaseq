process QIIME_ALPHA {
    label 'process_low'
    tag "${vectors.baseName}"

    container 'quay.io/qiime2/core:2023.2'

    when:
    !params.skip_alphadiversity

    input:
    path(vectors)
    path(group_metadata)
    
    output:
    path("alpha_diversity/*.tsv"), optional:true, emit: metadata_tsv
    path("alpha_diversity/*.qzv") 

    script:
    """
    qiime diversity alpha-group-significance \
        --i-alpha-diversity ${vectors.baseName}.qza \
        --m-metadata-file $group_metadata \
        --o-visualization ${vectors.baseName}_vis.qzv

    qiime tools export --input-path ${vectors.baseName}_vis.qzv --output-path "alpha_diversity/${vectors.baseName}"

    mv ${vectors.baseName}_vis.qzv alpha_diversity/${vectors.baseName}_alpha.qzv
    cp "alpha_diversity/${vectors.baseName}/metadata.tsv" "alpha_diversity/${vectors.baseName}.tsv"
    """
}
