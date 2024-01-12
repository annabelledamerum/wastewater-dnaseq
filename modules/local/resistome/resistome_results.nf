process RESISTOME_RESULTS {
    label 'process_medium'

    input:
    path(classes)
    path(genes)
    path(mechanism)
    path(group)
    path(bam_flagstats)

    output:
    path("class_rawcounts_AMR_analytic_matrix.csv"),     emit: class_count_matrix
    path("mechanism_rawcounts_AMR_analytic_matrix.csv"), emit: mechanism_count_matrix
    path("genes_rawcounts_AMR_analytic_matrix.csv"),     emit: gene_count_matrix
    path("*normalized_AMR_analytic_matrix.csv")
    path("class_resistomechart_mqc.json"),     emit: class_resistome_count_matrix
    path("genelevel_resistomechart_mqc.json"),  emit: top20_genelevel_resistome

    script:
    """
    
    amr_long_to_wide.py -i $classes -o class_rawcounts_AMR_analytic_matrix.csv
    amr_long_to_wide.py -i $genes -o genes_rawcounts_AMR_analytic_matrix.csv
    amr_long_to_wide.py -i $mechanism -o mechanism_rawcounts_AMR_analytic_matrix.csv
    normalize_amr.py -r "class_rawcounts_AMR_analytic_matrix.csv" "genes_rawcounts_AMR_analytic_matrix.csv" "mechanism_rawcounts_AMR_analytic_matrix.csv" -f $bam_flagstats
    display_resistome_stacked_mqc.py class_normalized_AMR_analytic_matrix.csv
    display_top20genes_mqc.py genes_normalized_AMR_analytic_matrix.csv
    """
}
