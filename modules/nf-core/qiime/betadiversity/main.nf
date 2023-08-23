process QIIME_BETADIVERSITY {
    tag "${pcoa.baseName}"
    label 'process_low'
    container "quay.io/qiime2/core:2023.2"

    when:
    !params.skip_betadiversity

    input:
    path(pcoa)
    path(metadata)

    output:
    path("*pcoa_results.tsv"), optional:true, emit: tsv
    path "versions.yml", emit: versions

    script:
    """ 
    qiime tools export --input-path ${pcoa.baseName}.qza \
        --output-path beta_diversity/${pcoa.baseName}
    #rename the output file name
    
    pcoa_ordination_totsv.py -p beta_diversity/${pcoa.baseName}/ordination.txt -c "${pcoa.baseName}" -m $metadata

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qiime: \$(qiime --version | sed '2,2d' | sed 's/q2cli version //g')
    END_VERSIONS
    """
}
