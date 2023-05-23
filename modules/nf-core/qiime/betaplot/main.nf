process QIIME_BETAPLOT {
    label 'process_low'

    input:
    path metadata
    path tsv

    output:
    path("beta_diversity_mqc.html"), optional:true, emit: report

    script:
        """
        #run the plotting script
            beta_diversity_plot.py "group" $metadata
        cp beta_diversity_plot* beta_diversity_mqc.html
        """
}
