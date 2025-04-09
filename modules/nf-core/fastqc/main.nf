process FASTQC {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::fastqc=0.11.9"
    container "quay.io/biocontainers/fastqc:0.11.9--0"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip") , emit: zip
    path  "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    if (meta.single_end) {
        """
        [ -f ${prefix}_R1.fastq.gz ] || ln -s ${reads[0]} ${prefix}_R1.fastq.gz

        fastqc $args --threads $task.cpus ${prefix}_R1.fastq.gz

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            fastqc: \$( fastqc --version | sed -e "s/FastQC v//g" )
        END_VERSIONS
        """
    } else {
        """
        [ -f ${prefix}_R1.fastq.gz ] || ln -s ${reads[0]} ${prefix}_R1.fastq.gz
        [ -f ${prefix}_R2.fastq.gz ] || ln -s ${reads[1]} ${prefix}_R2.fastq.gz

        fastqc $args --threads $task.cpus ${prefix}_R1.fastq.gz
        fastqc $args --threads $task.cpus ${prefix}_R2.fastq.gz

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            fastqc: \$( fastqc --version | sed -e "s/FastQC v//g" )
        END_VERSIONS
        """
    }
    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.html
    touch ${prefix}.zip

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastqc: \$( fastqc --version | sed -e "s/FastQC v//g" )
    END_VERSIONS
    """
}
