process QIIME_DATAMERGE {
    label 'process_low'

    container 'quay.io/qiime2/core:2023.2'    

    input:
    path(qza)

    output:
    path('allsamples_mergedqiime.qza')   , emit: qiime_qzamerged
    path('allsamples_relcounts.txt'),       emit: allsamples_relcounts

    script:

    """
    qiime feature-table merge --i-tables $qza --o-merged-table allsamples_mergedqiime.qza

    qiime tools export --input-path allsamples_mergedqiime.qza --output-path allsamples_relcounts_out/

    biom convert -i allsamples_relcounts_out/feature-table.biom -o allsamples_relcounts.txt --to-tsv
    """
}
