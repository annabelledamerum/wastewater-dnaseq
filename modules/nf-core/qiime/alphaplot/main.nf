params.diversity_fileoutput = false

process QIIME_ALPHAPLOT {
    when:
    !params.skip_alphadiversity || !params.skip_alpha_rarefaction
    
    input:
    path metadata
    path alpha_diversity_plot
    path rarefaction_plot

    output:
    path "*_mqc.*", emit: mqc_plot

    script:
    alphaoutput =  params.diversity_fileoutput ? "comparative_alpha_diversity_mqc.html" : "alpha_diversity_mqc.html"
    rareoutput  = params.diversity_fileoutput ? "comparative_alpha_rarefaction_mqc.html" : "alpha_rarefaction_mqc.html"
    alpha_diversity_plot = params.skip_alphadiversity ? '' : "alphadiversity.py --observed_features observed_features_vector.tsv --shannon shannon_vector.tsv --evenness evenness_vector.tsv --output_file $alphaoutput"
    alphararefaction_plot = params.skip_alpha_rarefaction ? '' : "alphararefaction.py -o observed_features.csv -s shannon.csv -w $rareoutput" 
    individ_alpha_diversity = params.skip_individalpha ? '' : 'display_qiimealpha_mqc.py -a shannon_vector.tsv' 
    """
    $alpha_diversity_plot
    $alphararefaction_plot
    $individ_alpha_diversity
    """
}

