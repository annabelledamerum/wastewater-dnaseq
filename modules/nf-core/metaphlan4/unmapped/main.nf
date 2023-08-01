process METAPHLAN4_UNMAPPED {
    label 'process_single'

    input: 
    path(mpa_info)

    output:
    path("mpa_readstats_mqc.json"), emit: json

    script:
    """
    display_unmapped_mpareads_mqc.py -i $mpa_info
    """

}
