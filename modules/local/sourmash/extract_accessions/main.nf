process SOURMASH_EXTRACT {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), path(gather)
    tuple val(meta), path(krona)

    output:
    path("*_accessions.txt"), emit: accessions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    awk 'BEGIN {FS=","}
    NR > 1 && \$5 >= 0.01 {
        accession=\$10
        # removes leading quotations if present
        gsub("\\"", "", accession)
        # only keeps the first word (the accession number)
        gsub(/\s.*\$/, "", accession)
        print accession
    }' ${input} > ${prefix}_accessions.txt

    # [ -s ${prefix}_accessions.txt ] || cut -f 1 ${fai} > ${meta.id}_accessions.txt
    """
}

