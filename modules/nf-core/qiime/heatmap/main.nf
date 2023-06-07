params.top_taxa = 20

process QIIME_HEATMAP {
    input:
    path rel_tax
    path metadata

    output:
    path("*taxo_heatmap.csv")  , emit: taxo_heatmap

    script:
    """
    sed '1,1d' $rel_tax | sed 's/#//g' > allsamples_clean_reltax.txt

    heatmap_input.r allsamples_clean_reltax.txt $metadata $params.top_taxa

    """
}
