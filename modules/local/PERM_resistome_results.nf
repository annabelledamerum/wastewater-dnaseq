process RESISTOME_RESULTS {
    label 'process_medium'

    input:
    path(gene)
    path(group)
    path(mechanism)
    path(class)

    output:
    path("class_resistomechart_mqc.json"),         emit: class_resistome_mqc
    path("gene_AMR_analytic_matrix.csv"),          emit: gene_resistome_count_matrix
    path("group_AMR_analytic_matrix.csv"),         emit: group_resistome_count_matrix
    path("mechanism_AMR_analytic_matrix.csv"),     emit: mechanism_resistome_count_matrix
    path("class_AMR_analytic_matrix.csv"),         emit: class_resistome_count_matrix


    script:
    """
    amr_long_to_wide.py -i $gene -o gene_AMR_analytic_matrix.csv
    amr_long_to_wide.py -i $group -o group_AMR_analytic_matrix.csv
    amr_long_to_wide.py -i $mechanism -o mechanism_AMR_analytic_matrix.csv
    amr_long_to_wide.py -i $class -o class_AMR_analytic_matrix.csv

    resistome_stacked_multiqc.py class_AMR_analytic_matrix.csv
    """
}
