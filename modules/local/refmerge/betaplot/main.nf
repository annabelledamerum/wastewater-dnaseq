process REFMERGE_BETAPLOT {
    label 'process_low'

    when:
    !params.skip_betadiversity && !params.skip_betadiversity_plot

    input:
    path metadata
    path tsv

    output:
    path("comparative_beta_diversity_mqc.html"), optional:true, emit: report


    script:
    """
    #run the plotting script
    refmerge_beta_diversity_plot.py "group" $metadata
    cp refmerge_beta_diversity_plot* comparative_beta_diversity_mqc.html
    """
}
