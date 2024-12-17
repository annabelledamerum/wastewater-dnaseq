process PATHOGEN_RESULTS{
    label 'process_low'
    cache false

    input:
    path(coverage_metrics, stageAs: "samtools_coverage/*")
    path(pathogen_metadata)

    output:
    path("coverage.csv"), emit: cov_metrics
    path("coverage_heatmap.png"), emit: heatmap


    script:
    """
    pathogen_coverage_results.py \
        --coverage_directory ./samtools_coverage/ \
        --metadata_file ${pathogen_metadata}
    """
}