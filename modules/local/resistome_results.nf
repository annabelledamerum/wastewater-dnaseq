process RESISTOME_RESULTS {
    label 'process_medium'

    input:
    path(resistomes)

    output:
    path("AMR_analytic_matrix.csv"),     emit: raw_count_matrix
    path("AMR_analytic_matrix.csv"),     emit: snp_count_matrix, optional: true
    path("perc_AMR_analytic_matrix.csv"), emit: analytic_matrix

    script:
    """
    amr_long_to_wide.py -i $resistomes -o AMR_analytic_matrix.csv
    parse_AMRmatrix.py -i AMR_analytic_matrix.csv -o perc_AMR_analytic_matrix.csv 
    """
}
