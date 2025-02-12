process QIIME_ANCOMBC {
    label 'process_low'

    container 'quay.io/qiime2/core:2023.2'

    input:
    path(qza)
    path(filtered_metadata)

    output:
    path "versions.yml"       , emit: versions
    path "ancombc.qza"        , emit: ancombc
    path "to_multiqc/*/*ancombc-barplot.html", emit: ancombc_mqc
    path "refgroup.txt"       , emit: reference_group
    path "*ancombc_group_overview.csv"

    script:
    """
    qiime composition ancombc \
        --i-table $qza \
        --m-metadata-file $filtered_metadata \
        --p-formula group \
        --o-differentials ancombc.qza

    qiime tools export --input-path ancombc.qza --output-path ancombc_export/

    mkdir to_multiqc/

    parse_ancom_output.py -l "./ancombc_export/lfc_slice.csv" -s "./ancombc_export/se_slice.csv" -q "./ancombc_export/q_val_slice.csv"  -w "./ancombc_export/w_slice.csv" -p "./ancombc_export/p_val_slice.csv" -f $filtered_metadata

    for dir in \$(find ./to_multiqc/ -maxdepth 1 -mindepth 1 -type d) 
    do 
        qiime tools import \
            --input-path \$dir \
            --type 'FeatureData[DifferentialAbundance]' \
            --output-path \${dir}_ancombc.qza

        qiime composition da-barplot --i-data \${dir}_ancombc.qza --o-visualization \${dir}_visualization 

        qiime tools export --input-path \${dir}_visualization.qzv --output-path \${dir}_visualization_export/

    done 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qiime: \$(qiime --version | sed '2,2d' | sed 's/q2cli version //g')
    END_VERSIONS
    """
}
