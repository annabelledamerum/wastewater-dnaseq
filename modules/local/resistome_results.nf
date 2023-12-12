process RESISTOME_RESULTS {
    label 'process_medium'

    input:
    path(classes)
    path(genes)
    path(mechanism)
    path(group)

    output:
    path("class_AMR_analytic_matrix.csv"),     emit: class_count_matrix
    path("mechanism_AMR_analytic_matrix.csv"), emit: mechanism_count_matrix
    path("genes_AMR_analytic_matrix.csv"),     emit: gene_count_matrix, optional: true
    path("class_resistomechart_mqc.json"),     emit: class_resistome_count_matrix

    script:
    """
    amr_long_to_wide.py -i $classes -o class_AMR_analytic_matrix.csv
    amr_long_to_wide.py -i $genes -o genes_AMR_analytic_matrix.csv
    amr_long_to_wide.py -i $mechanism -o mechanism_AMR_analytic_matrix.csv
    resistome_stacked_multiqc.py class_AMR_analytic_matrix.csv
    """
}
