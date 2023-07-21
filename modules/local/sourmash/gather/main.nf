params.threshold_bp = 50000
params.kmersize = 51

process SOURMASH_GATHER {
    tag "$meta.id"
    label 'process_high_memory'
    container 'quay.io/biocontainers/sourmash:4.8.2--hdfd78af_0'

    input:
    tuple val(meta), path(sketch), path(sketch_log)
    path "sourmash_database"

    output:
    tuple val(meta), path('*with-lineages.csv'), emit: gather
    path "versions.yml", emit: versions
    path "*.log"

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"    
    """
    DB=`find -L "sourmash_database" -name "*${params.kmersize}.zip"`
    LINEAGE=`find -L "sourmash_database" -name "*.csv"`

    sourmash gather $sketch \$DB --dna --ksize ${params.kmersize} --threshold-bp ${params.threshold_bp} -o ${prefix}_sourmashgather.csv 2> ${prefix}_sourmashgather.log
    sourmash tax annotate -g ${prefix}_sourmashgather.csv -t \$LINEAGE 2> ${prefix}_sourmashannotate.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(sourmash --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}

