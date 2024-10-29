process RESISTOME_SNPRESULTS {
    label 'process_medium'

    input:
    path(snp_counts)
    path(bam_flagstats)
    path(amr_metadata)

    output:
    path("*genes_SNPconfirmed_analytic_matrix.csv"), emit: gene_counts_SNPverified, optional: true
    path("*genes_SNPconfirmed_normalized_AMR_analytic_matrix_wMetadata.csv"), emit: gene_counts_SNPverified_normalized, optional: true
    path("AMR_matrix_pivot.csv"), emit: amr_matrix_pivot, optional: true
    path("amr_heatmap.png"), emit: amr_heatmap, optional:true

    script:
    """
    snp_long_to_wide.py -i $snp_counts -o genes_SNPconfirmed_analytic_matrix.csv
    amrplusplus_summary.py --amr_counts genes_SNPconfirmed_analytic_matrix.csv --flagstats $bam_flagstats --amr_metadata $amr_metadata
    """
}
