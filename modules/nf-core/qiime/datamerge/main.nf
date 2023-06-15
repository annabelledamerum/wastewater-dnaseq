process QIIME_DATAMERGE {
    label 'process_low'

    container 'quay.io/qiime2/core:2023.2'    

    input:
    path(rel_qza)
    path(abs_qza)
    path(aligned_read_totals)

    output:
    path('mergedrelqiime.qza')   , emit: rel_qzamerged
    path('mergedabsqiime.qza')   , emit: abs_qzamerged
    path('allsamples_relcounts.txt'),       emit: allsamples_relcounts
    path('allsamples_abscounts.txt'),       emit: allsamples_abscounts
    path('readcount_maxsubset.txt'),        emit: readcount_maxsubset
    path('qza_lowqualityfiltered.txt'),     emit: samples_filtered
    

    script:

    """
    qiime feature-table merge --i-tables $rel_qza --o-merged-table mergedrelqiime.qza

    qiime tools export --input-path mergedrelqiime.qza --output-path allsamples_relcounts_out/

    biom convert -i allsamples_relcounts_out/feature-table.biom -o allsamples_relcounts.txt --to-tsv

    low_read_filter.py -q "$abs_qza" -r $aligned_read_totals

    qiime feature-table merge --i-tables \$( < qza_lowqualityfiltered.txt) --o-merged-table mergedabsqiime.qza

    qiime tools export --input-path mergedabsqiime.qza --output-path allsamples_abscounts_out/

    biom convert -i allsamples_abscounts_out/feature-table.biom -o allsamples_abscounts.txt --to-tsv
    """
}
