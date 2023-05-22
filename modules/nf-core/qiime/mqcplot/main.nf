process QIIME_MQCPLOT {

    input:
    path metadata
    path alpha_diversity_plot

    output:
    path "*_mqc.*", emit: mqc_plot

    script:
    alpha_diversity_plot = 'alphadiversity.py --shannon shannon_vector.tsv --evenness evenness_vector.tsv --observed_features observed_features_vector.tsv --output_file Alpha_Diversity_mqc.html'
    
    """
    $alpha_diversity_plot

    display_qiimealpha_mqc.py -a shannon_vector.tsv
    """
}

