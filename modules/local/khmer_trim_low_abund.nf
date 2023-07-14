// User trim_low_abund.py of khmer to preprocess reads

process KHMER_TRIM_LOW_ABUND {
    tag "${meta.id}"
    label 'process_low'
    container 'quay.io/biocontainers/khmer:3.0.0a3--py38h94ffb2d_3'

    input:
    tuple val(meta), path(input)

    output:
    tuple val(meta), path("*.abundtrim"), emit: reads
    path "versions.yml", emit: versions
    path "*.log", emit: logs

    script:
    mem_param = "${task.memory.toGiga()/2}e9"
    """
    trim-low-abund.py -C 3 -Z 18 -V -M $mem_param $input 2> ${meta.id}_khmer.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        khmer: \$(trim-low-abund.py --version 2>&1 | grep '^khmer' | awk '{print \$2}')
    END_VERSIONS
    """
}