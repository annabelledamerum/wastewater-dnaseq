process REFMERGE_MERGEMETA {
    label 'process_low'

    conda (params.enable_conda ? "bioconductor-dada2=1.22.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bioconductor-dada2:1.22.0--r41h399db7b_0' :
        'quay.io/biocontainers/bioconductor-dada2:1.22.0--r41h399db7b_0' }"

    input:
    path(user), stageAs: 'user_meta.tsv'
    path(ref), stageAs: 'ref_meta.tsv'

    output:
     path("merged_metadata.tsv")  , emit: metadata

    script:
    """
    awk '(NR == 1) || (FNR > 1)' 'user_meta.tsv' 'ref_meta.tsv' > merged_metadata.tsv
    """
}
