process QIIME_QIIME {
    label 'process_medium'
    
    conda "bioconda::qiime=1.9.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/qiime:1.9.1--py_3' :
        'quay.io/biocontainers/qiime:1.9.1--py_3' }"
    
    input:
    tuple val(meta), path(biom)

    output:
    path('qiime_summarize_taxa/*.txt')   , emit: composition
    path('qiime_summarize_taxa/*.biom')
    path "versions.yml"                  , emit: versions
    

    script:
    """
    summarize_taxa.py -i ${biom} -o qiime_summarize_taxa/  
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qiime: \$(print_qiime_config.py --version 2>&1 | sed 's/Version: print_qiime_config.py //')
    END_VERSIONS
    """
}
