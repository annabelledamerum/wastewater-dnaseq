process BWA_ALIGN {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::bwa=0.7.18"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-fe8faa35dbf6dc65a0f7f5d4ea12e31a79f73e40:1bd8542a8a0b42e0981337910954371d0230828e-0' :
        'quay.io/biocontainers/mulled-v2-fe8faa35dbf6dc65a0f7f5d4ea12e31a79f73e40:1bd8542a8a0b42e0981337910954371d0230828e-0' }"
    
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
    INDEX=`find -L ./ -name "*.amb" | sed 's/\\.amb\$//'` 

    bwa mem \$INDEX ${input} -t $task.cpus -R '@RG\\tID:${prefix}\\tSM:${prefix}' > ${prefix}_alignment.sam
    samtools view -@ $task.cpus -S -b ${prefix}_alignment.sam > ${prefix}_alignment.bam
    rm ${prefix}_alignment.sam
    samtools sort -@ $task.cpus -o ${prefix}_alignment_sorted.bam ${prefix}_alignment.bam
    rm ${prefix}_alignment.bam     
    samtools flagstat ${prefix}_alignment_sorted.bam > ${prefix}_flagstat.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa: \$(echo \$(bwa 2>&1) | sed 's/^.*Version: //; s/Contact:.*\$//')
        samtools: \$(echo \$(samtools --version-only 2>&1))
    END_VERSIONS
    """
}
