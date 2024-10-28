process PATHOGEN_RESULTS{
    tag "${meta.id}"
    label 'process_low'

    input:
    path(coverage_metrics, stageAs: "samtools_coverage/*")
    path(pathogen_metadata)

    output:
    path("coverage.csv"), emit: cov_metrics



    script:
    """
    pathogen_coverage_results.py \
        --coverage_directory ./samtools_coverage/ \
        --metadata_file $pathogen_metadata
    """
}