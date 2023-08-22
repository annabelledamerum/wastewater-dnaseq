params.diversity_fileoutput = false

process QIIME_BETAPLOT {
    label 'process_low'

    when:
    !skip_betadiversity

    input:
    path tsv

    output:
    path("*beta_diversity_mqc.html"), optional:true, emit: report

    script:
    betaoutput =  params.diversity_fileoutput ? "comparative_beta_diversity_mqc.html" : "beta_diversity_mqc.html"
    """
    #run the plotting script
    beta_diversity_plot.py "group" $metadata
    cp beta_diversity_plot* $betaoutput
    """
}
