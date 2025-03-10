// Make plotly figures for varoius diversity plot to include in MultiQC report
process QIIME_PLOT_MULTIQC {    
    input:
    path metadata
    path pcoa
    path alpha_diversity_plot
    path rarefaction_plot
    val ref_comparison
    val rarefaction_skip

    output:
    path "*_mqc.*", emit: mqc_plot

    script:
    alphaoutput =  ref_comparison ? "comparative_alpha_diversity_mqc.html" : "alpha_diversity_mqc.html"
    rareoutput  = ref_comparison ? "comparative_alpha_rarefaction_mqc.html" : "alpha_rarefaction_mqc.html"
    betaoutput = ref_comparison ? "-o comparative_beta_diversity_mqc.html" : ""
    alpha_diversity_plot = params.skip_alphadiversity ? '' : "alphadiversity.py --observed_features observed_features_vector.tsv --shannon shannon_vector.tsv --evenness evenness_vector.tsv --output_file $alphaoutput"
    alphararefaction_plot = rarefaction_skip ? '' : "alphararefaction.py -o observed_features.csv -s shannon.csv -w $rareoutput" 
    individ_alpha_diversity = params.skip_individalpha ? '' : 'display_qiimealpha_mqc.py -a shannon_vector.tsv' 
    beta_pcoa_plot = params.skip_betadiversity ? '' : "betadiversity_pcoa.py $pcoa -m $metadata $betaoutput"
    """
    $alpha_diversity_plot
    $alphararefaction_plot
    $individ_alpha_diversity
    $beta_pcoa_plot
    """
}

