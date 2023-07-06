process SOURMASH_GATHER {
    tag "$meta.id"
    label 'process_high'

    input:
    tuple val(meta), path(sketch), path(readcount)
    path sourmash_db

    output:
    tuple val(meta), path('*with-lineages.csv'), path('*_sketchfq_readcount.txt'),   emit: gather     
    path "versions.yml"                            ,   emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"    
    """
    DB=`find -L "${sourmash_db}" -name "*k51.zip"`
    LINEAGE=`find -L "${sourmash_db}" -name "*.csv"`

    sourmash gather $sketch \$DB --dna --ksize 51 --threshold-bp 50000 -o sourmash_gather_output 2>> ${prefix}_sourmashgather.log
    sourmash tax annotate -g sourmash_gather_output -t \$LINEAGE 2>> ${prefix}_sourmashannotate.log    
    mv $readcount ${prefix}_sketchfq_readcount.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(sourmash --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}

