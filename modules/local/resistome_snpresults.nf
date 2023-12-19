process RESISTOME_SNPRESULTS {
    label 'process_medium'

    input:
    path(snp_counts)

    output:
    path("*genes_SNPconfirmed_analytic_matrix.csv"),     emit: gene_counts_SNPverified, optional: true

    script:
    """
    snp_long_to_wide.py -i $snp_counts -o genes_SNPconfirmed_analytic_matrix.csv
    """
}
