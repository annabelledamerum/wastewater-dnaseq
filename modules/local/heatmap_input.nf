process HEATMAP_INPUT {

    input:
    path rel_tax
    path metadata
    val top_taxa

    output:
    path("*taxo_heatmap.csv")  , emit: taxo_heatmap

    script:
    """
    heatmap_input.py $rel_tax -m $metadata -t $top_taxa
    """
}