process QIIME_BETA {
    tag "${distance.baseName}"
    label 'process_low'
    container "quay.io/qiime2/core:2023.2"

    input:
    path(distance)
    path(metadata)
    path(group_list)

    output:
    path("beta_diversity/*"), emit: beta
    path("beta_diversity/beta_qzv/*.qzv"), emit: qzv
    path("*.tsv"), optional:true, emit: tsv


    script:
    """
    qiime diversity beta-group-significance \
        --i-distance-matrix ${distance} \
        --m-metadata-file ${metadata} \
        --m-metadata-column "group" \
        --o-visualization ${distance.baseName}-group.qzv \
        --p-pairwise
    qiime tools export --input-path ${distance.baseName}-group.qzv \
        --output-path beta_diversity/${distance.baseName}-group
    #rename the output file name
    mkdir beta_diversity/beta_qzv/
    mv ${distance.baseName}-group.qzv beta_diversity/beta_qzv/${distance.baseName}_beta-group.qzv
    mv beta_diversity/${distance.baseName}-group/raw_data.tsv ${distance.baseName}-group.tsv
    """
}
