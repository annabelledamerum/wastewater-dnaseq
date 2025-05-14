process SOURMASH_REPORT2KRONA {
    label 'process_low'

    conda (params.enable_conda ? { exit 1 "QIIME2 has no conda package" } : null)

    input:
    input val(meta), path(rel_tsv)

    output:
    path "*.txt", emit: krona_input

    script:
    def prefix = "${meta.sample}"
    """
    parse_sourmash_for_krona.py -n ${prefix} $rel_tsv    
    """
}
