process REFMERGE_ALPHAPLOT {

    when:
    !params.skip_alphadiversity || !params.skip_alpha_rarefaction

    input:
    path metadata
    path rarefaction_plot
    path alpha_diversity_plot

    output:
    path "*_mqc.*", emit: mqc_plot

    script:
    alpha_diversity_plot = (params.skip_alphadiversity ) ? '' : 'refmerge_alpha_diversity_plot.py --shannon shannon_vector.tsv --evenness evenness_vector.tsv --observed_features observed_features_vector.tsv --output_file comparative_alpha_diversity_mqc.html'
    alphararefaction_plot = params.skip_alpha_rarefaction ? '' : 'alphararefaction.py -o observed_features.csv -s shannon.csv -w comparative_alpha_rarefaction_mqc.html'

    """
    $alphararefaction_plot
    $alpha_diversity_plot
    """
}
