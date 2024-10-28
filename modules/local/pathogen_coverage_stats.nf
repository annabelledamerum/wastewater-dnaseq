process PATHOGEN_COVERAGE{
    tag "${meta.id}"
    label 'process_low'

    input:
    path(coverage_metrics, stageAs: "samtools_coverage/*")
    path(pathogen_metadata)

    output:
    tuple val(meta), path("*.csv"), emit: cov_metrics

    script:
    """
    converge_metrics.py \
        --coverage_directory ./samtools_coverage/ \
        --metadata_file ${pathogen_metadata} \
        --output_dir ./
    """
}