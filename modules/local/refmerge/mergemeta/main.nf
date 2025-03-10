process REFMERGE_MERGEMETA {

    input:
    path(user), stageAs: 'user_meta.tsv'
    path(ref), stageAs: 'ref_meta.tsv'

    output:
    path("merged_metadata.tsv") , emit: metadata

    script:
    """
    awk '(NR == 1) || (FNR > 1)' 'user_meta.tsv' 'ref_meta.tsv' > merged_metadata.tsv
    """
}
