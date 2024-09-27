// Collect and parse information about files for download on the aladdin platform

process SUMMARIZE_DOWNLOADS {
    cache false

    input:
    path locations
    path design

    output:
    path 'files_to_download.json'

    script:
    """
    summarize_downloads.py $locations -d $design
    """
}