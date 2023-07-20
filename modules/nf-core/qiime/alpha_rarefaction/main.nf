process QIIME_ALPHARAREFACTION {
    label 'process_low'

    container "quay.io/qiime2/core:2023.2"

    when:
    !params.skip_alpha_rarefaction
    
    input:
    path(metadata)
    path(table)
    path(maxdepth_file)

    output:
    path("alpha-rarefaction/*")                             , emit: rarefaction
    path("alpha-rarefaction/*.csv")                         , optional:true, emit: rarefaction_csv
    path("alpha-rarefaction/alpha-rarefaction.qzv")         , emit: alpha_rarefaction_qzv

    script:
    """
    #check values
    maxdepth=\$( < $maxdepth_file )
    if [ \"\$maxdepth\" -gt \"250000\" ]; then maxdepth=\"250000\"; fi
    maxsteps=\"50\"

    qiime diversity alpha-rarefaction  \
        --i-table ${table}  \
        --p-max-depth \$maxdepth  \
        --m-metadata-file ${metadata}  \
        --p-steps \$maxsteps  \
        --p-iterations 5 \
        --o-visualization alpha-rarefaction.qzv
    qiime tools export --input-path alpha-rarefaction.qzv  \
        --output-path alpha-rarefaction

    # mv alpha-rarefaction/index.html  alpha-rarefaction/alpha-rarefaction_index.html
    mv alpha-rarefaction.qzv alpha-rarefaction/alpha-rarefaction.qzv
    """
}
