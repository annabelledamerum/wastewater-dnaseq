process REFMERGE_DIVERSITYCORE {
    label 'process_low'

    conda (params.enable_conda ? { exit 1 "QIIME2 has no conda package" } : null)
    container "quay.io/qiime2/core:2023.2"

    input:
    path(metadata)
    path(table)
    val(min_total)

    output:
    path("diversity_core/*_pcoa_results.qza")   , emit: pcoa
    path("diversity_core/*_vector.qza")         , emit: vector
    path("diversity_core/*_distance_matrix.qza"), emit: distance
    path("diversity_core/*.qzv")                , emit: qzv
    path "versions.yml"                         , emit: versions
    path ("Outlier_samples_mqc.txt")            , optional:true, emit:sample_removed
    script:
    """
    qiime diversity core-metrics  \
        --i-table ${table} \
        --p-sampling-depth ${min_total.toInteger()} \
        --m-metadata-file ${metadata} \
        --output-dir diversity_core \
        --p-n-jobs ${task.cpus} \
        --verbose

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qiime2: \$( qiime --version | sed -e "s/q2cli version //g" | tr -d '`' | sed -e "s/Run qiime info for more version details.//g" )
    END_VERSIONS
    """
}
