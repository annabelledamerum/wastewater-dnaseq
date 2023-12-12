process RESISTOME_RESULTS {
    label 'process_medium'

    input:
    path(resistomes)

    output:
    path("*AMR_analytic_matrix.csv"),     emit: raw_count_matrix
    path("*AMR_analytic_matrix.csv"),     emit: snp_count_matrix, optional: true
    path("class_resistomechart_mqc.json"),     emit: class_resistome_count_matrix

    script:
    """
    amr_long_to_wide.py -i $resistomes -o class_AMR_analytic_matrix.csv
    resistome_stacked_multiqc.py class_AMR_analytic_matrix.csv
    """
}
