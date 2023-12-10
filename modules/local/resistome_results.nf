process RESISTOME_RESULTS {
    label 'process_medium'

    input:
    path(resistomes)

    output:
    path("*analytic_matrix.csv"), emit: raw_count_matrix
    path("*analytic_matrix.csv"), emit: snp_count_matrix, optional: true

    script:
    """
    amr_long_to_wide.py -i $resistomes -o AMR_analytic_matrix.csv
    """
}
