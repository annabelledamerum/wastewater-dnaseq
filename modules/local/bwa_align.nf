process BWA_ALIGN {
    tag "$meta.id"
    label 'process_high'

    input:
    path ref_index_files
    tuple val(meta), path(input)

    output:
    tuple val(meta), path("*_alignment_sorted.bam"), emit: bwa_bam
    tuple val(meta), path("*_alignment_dedup.bam"), emit: bwa_dedup_bam, optional: true
    path("*_flagstat.txt"), emit: bam_flagstats
    path "versions.yml", emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bwa mem ${ref_index_files}/ndaro_2024-07-22.fasta ${input} -t $task.cpus -R '@RG\\tID:${prefix}\\tSM:${prefix}' > ${prefix}_alignment.sam
    samtools view -@ $task.cpus -S -b ${prefix}_alignment.sam > ${prefix}_alignment.bam
    rm ${prefix}_alignment.sam
    samtools sort -@ $task.cpus -n ${prefix}_alignment.bam -o ${prefix}_alignment_sorted.bam
    rm ${prefix}_alignment.bam     
    samtools flagstat ${prefix}_alignment_sorted.bam > ${prefix}_flagstat.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa: \$(echo \$(bwa 2>&1) | sed 's/^.*Version: //; s/Contact:.*\$//')
        samtools: \$(echo \$(samtools --version-only 2>&1))
    END_VERSIONS
    """
}
