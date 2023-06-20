params.lowread_filter = 1000000

process QIIME_DATAMERGE {
    label 'process_low'

    container 'quay.io/qiime2/core:2023.2'    

    input:
    path(rel_qza)
    path(abs_qza)
    path(aligned_read_totals)

    output:
    path('allsamples_mergedrelqiime.qza')   ,          emit: allsamples_rel_qzamerged
    path('filtered_mergedabsqiime.qza')   ,          emit: filtered_abs_qzamerged
    path('filtered_samples_relcounts.txt'), emit: filtered_samples_relcounts
    path('filtered_samples_abscounts.txt'), emit: filtered_samples_abscounts
    path('readcount_maxsubset.txt'),        emit: readcount_maxsubset
    path('absqza_lowqualityfiltered.txt'),  emit: samples_filtered
   
    //All samples' qza with relative counts are merged for use in qiime composition barplot
    //All sample's qza with absolute counts are filtered by read count for use in group diversity comparisons
    //TXT file with all abs sample names that were already filtered for low quality are changed for relative count files
    //Filtered samples' qza with relative counts are merged for use in heatmap comparison

    script:
    """
    qiime feature-table merge --i-tables $rel_qza --o-merged-table allsamples_mergedrelqiime.qza

    low_read_filter.py -q "$abs_qza" -r $aligned_read_totals -f $params.lowread_filter

    qiime feature-table merge --i-tables \$( < absqza_lowqualityfiltered.txt) --o-merged-table filtered_mergedabsqiime.qza

    qiime tools export --input-path filtered_mergedabsqiime.qza --output-path filtered_samples_abscounts_out/

    biom convert -i filtered_samples_abscounts_out/feature-table.biom -o filtered_samples_abscounts.txt --to-tsv

    qiime feature-table merge --i-tables \$(sed 's/_qiime_absfreq_table.qza/_qiime_relfreq_table.qza/g' absqza_lowqualityfiltered.txt) --o-merged-table filtered_mergedrelqiime.qza

    qiime tools export --input-path filtered_mergedrelqiime.qza --output-path filteredsamples_relcounts_out/

    biom convert -i filteredsamples_relcounts_out/feature-table.biom -o filtered_samples_relcounts.txt --to-tsv
    """
}
