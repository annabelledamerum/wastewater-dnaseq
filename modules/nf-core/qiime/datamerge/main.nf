/* 
Merge sample feature table qza
Filter sample by no. reads
Merge sample taxonomy and import to qiime
Collapse at specified taxa
Convert to relative abundance
Output raw and filtered count tables
*/ 

process QIIME_DATAMERGE {
    label 'process_low'

    container 'quay.io/qiime2/core:2023.2'    

    input:
    path(abs_qza)
    path(taxonomy)

    output:
    path('merged_filtered_counts.qza')             , emit: filtered_counts_qza
    path('merged_taxonomy.qza')                    , emit: taxonomy_qza
    path('merged_raw_counts_collapsed.tsv')        , emit: raw_counts_tsv
    path('merged_filtered_counts_collapsed.qza')   , emit: filtered_counts_collapsed_qza
    path('merged_filtered_counts_collapsed.tsv')   , emit: filtered_counts_tsv
    path('merged_filtered_rel_freq_collapsed.tsv') , emit: filtered_relfreq_tsv
    path('versions.yml')                           , emit: versions
    path('*.qza')

    script:
    """
    qiime feature-table merge \
        --i-tables $abs_qza \
        --o-merged-table merged_raw_counts.qza

    qiime feature-table filter-samples \
        --i-table merged_raw_counts.qza \
        --p-min-frequency ${params.lowread_filter} \
        --o-filtered-table merged_filtered_counts.qza
    
    qiime_taxmerge.py $taxonomy
    qiime tools import \
        --input-path merged_taxonomy.tsv \
        --type 'FeatureData[Taxonomy]' \
        --input-format TSVTaxonomyFormat \
        --output-path merged_taxonomy.qza
    
    qiime taxa collapse \
        --i-table merged_raw_counts.qza \
        --i-taxonomy merged_taxonomy.qza \
        --p-level ${params.taxonomy_collapse_level} \
        --o-collapsed-table merged_raw_counts_collapsed.qza

    qiime tools export \
        --input-path merged_raw_counts_collapsed.qza \
        --output-path merged_raw_counts_collapsed_out
    biom convert -i merged_raw_counts_collapsed_out/feature-table.biom -o merged_raw_counts_collapsed.tsv --to-tsv

    qiime feature-table filter-samples \
        --i-table merged_raw_counts_collapsed.qza \
        --p-min-frequency ${params.lowread_filter} \
        --o-filtered-table merged_filtered_counts_collapsed.qza

    qiime tools export \
        --input-path merged_filtered_counts_collapsed.qza \
        --output-path merged_filtered_counts_collapsed_out
    biom convert -i merged_filtered_counts_collapsed_out/feature-table.biom -o merged_filtered_counts_collapsed.tsv --to-tsv

    qiime feature-table relative-frequency \
        --i-table merged_filtered_counts_collapsed.qza \
        --o-relative-frequency-table merged_filtered_rel_freq_collapsed.qza

    qiime tools export \
        --input-path merged_filtered_rel_freq_collapsed.qza \
        --output-path merged_filtered_rel_freq_collapsed_out
    biom convert -i merged_filtered_rel_freq_collapsed_out/feature-table.biom -o merged_filtered_rel_freq_collapsed.tsv --to-tsv
        
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qiime: \$(qiime --version | sed '2,2d' | sed 's/q2cli version //g')
        biom: \$(biom --version | sed 's/biom, version //')
    END_VERSIONS 

   """
}
