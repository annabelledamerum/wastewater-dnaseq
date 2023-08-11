// Remove samples from Qiime feature table that are not in the metadata file
// Covert to relative freq tsv for heatmap

process QIIME_FILTER_SINGLETON_SAMPLE {

    label 'process_low'

    container 'quay.io/qiime2/core:2023.2'

    input:
    path(qza)
    path(metadata)

    output:
    path('abs_feature_table_for_diversity.qza'), emit: abs_qza
    path('rel_feature_table_for_diversity.tsv'), emit: rel_tsv
    path('versions.yml')                       , emit: versions
    path('*.qza')

    script:
    """
    qiime feature-table filter-samples \
        --i-table $qza \
        --m-metadata-file $metadata \
        --p-no-exclude-ids \
        --o-filtered-table abs_feature_table_for_diversity.qza

    qiime feature-table relative-frequency \
        --i-table abs_feature_table_for_diversity.qza \
        --o-relative-frequency-table rel_feature_table_for_diversity.qza

    qiime tools export \
        --input-path rel_feature_table_for_diversity.qza \
        --output-path rel_feature_table_for_diversity_out
    biom convert -i rel_feature_table_for_diversity_out/feature-table.biom -o rel_feature_table_for_diversity.tsv --to-tsv
        
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qiime: \$(qiime --version | sed '2,2d' | sed 's/q2cli version //g')
        biom: \$(biom --version | sed 's/biom, version //')
    END_VERSIONS 
    """
}