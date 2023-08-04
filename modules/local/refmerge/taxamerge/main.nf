process REFMERGE_TAXAMERGE {
    tag "min-freq:${min_frequency};min-samples:${min_samples}"
    label 'process_low'

    conda (params.enable_conda ? { exit 1 "QIIME2 has no conda package" } : null)
    container "quay.io/qiime2/core:2021.8"

    input:
    path(ch_user_table), stageAs: 'user_table.qza'
    path(ch_tax), stageAs: 'user_taxonomy.qza'
    path(ch_ref_table), stageAs: 'ref_table.qza'
    path(ch_ref_tax), stageAs: 'ref_taxonomy.qza'
    val(refmerge_collapse_level)
    val(min_frequency)
    val(min_samples)

    output:
    path("refmerged_filtered-table.qza"), emit: merged
    path("refmerge_filtered-table.tsv"), emit: tsv

    script:
    """
    export XDG_CONFIG_HOME="\${PWD}/HOME"

    # collapse user and ref taxa table to genus level, respectively
    qiime taxa collapse \
        --i-table user_table.qza \
        --i-taxonomy user_taxonomy.qza \
        --p-level ${refmerge_collapse_level} \
        --o-collapsed-table user_table-${refmerge_collapse_level}.qza 
    
    qiime taxa collapse \
        --i-table ref_table.qza \
        --i-taxonomy ref_taxonomy.qza \
        --p-level ${refmerge_collapse_level} \
        --o-collapsed-table ref_table-${refmerge_collapse_level}.qza

    # merge user and ref tables
    qiime feature-table merge \
        --i-tables user_table-6.qza ref_table-6.qza \
        --o-merged-table refmerged-table.qza

    qiime feature-table filter-features \
        --i-table refmerged-table.qza \
        --p-min-frequency ${min_frequency} \
        --p-min-samples ${min_samples} \
        --o-filtered-table refmerged_filtered-table.qza
    
    #produce raw count table in biom format "table/feature-table.biom"
    qiime tools export --input-path refmerged_filtered-table.qza  \
        --output-path table
    
    #produce raw count table
    biom convert -i table/feature-table.biom \
        -o table/feature-table.tsv  \
        --to-tsv
    cp table/feature-table.tsv refmerge_filtered-table.tsv
    """
}
