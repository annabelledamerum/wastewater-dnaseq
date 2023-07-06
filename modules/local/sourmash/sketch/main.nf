process SOURMASH_SKETCH {
    tag "$meta.id"
    label 'process_high'

    input:
    tuple val(meta), path(input)

    output:
    tuple val(meta), path('*.sig'), path('*_sketchfq_readcount.txt'), emit: sketch
    path "versions.yml"                                             , emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def input_type = ("$input".endsWith(".fastq.gz") || "$input".endsWith(".fq.gz")) ? "--input_type fastq" :  "--input_type fasta"
    def input_data  = ("$input_type".contains("fastq")) && !meta.single_end ? "${input[0]},${input[1]}" : "$input"
    def fastq1      = "${input[0]}"
    """
    echo \$((\$(zcat $fastq1 | wc -l) / 4)) > ${prefix}_sketchfq_readcount.txt
    sourmash sketch dna -p k=51,scaled=1000,abund \$( echo $input_data | sed 's/,/ /' ) -o ${prefix}.sig --name ${prefix} 2>> ${prefix}_sourmashsketch.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(sourmash --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}

