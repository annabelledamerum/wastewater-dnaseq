process SOURMASH_QIIMEPREP {
    label 'process_high'

    conda "bioconda::biom-format=2.1.7=py27_0"
    container 'quay.io/biocontainers/biom-format:2.1.7--py27_0'

    input:
    tuple val(meta), path(gather), path(readcount)

    output:
    tuple val(meta), path('*relabun_parsed_mpaprofile.biom'), path ('*absabun_parsed_mpaprofile.biom'),   emit: mpa_biomprofile
    path('*_sketchfq_readcount.txt')               ,   emit: fq_readcount
    path ('*profile_taxonomy.txt')                 ,   emit: taxonomy     
    path "versions.yml"                            ,   emit: versions

    script:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    profiler_parse_abun.py -t $gather -p "sourmash" -l ${prefix} -c \$( < $readcount )
    biom convert -i ${prefix}_relabun_parsed_mpaprofile.txt -o ${prefix}_relabun_parsed_mpaprofile.biom --table-type="OTU table" --to-json
    biom convert -i ${prefix}_absabun_parsed_mpaprofile.txt -o ${prefix}_absabun_parsed_mpaprofile.biom --table-type="OTU table" --to-json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(sourmash --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}

