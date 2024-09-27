process SOURMASH_QIIMEPREP {
    label 'process_low'
    tag "${meta.id}"

    conda "bioconda::biom-format=2.1.14"
    container 'quay.io/biocontainers/biom-format:2.1.14'

    input:
    tuple val(meta), path(gather), path(sketch_log)
    path host_lineage

    output:
    tuple val(meta), path ("*absabun_profile.biom"), emit: biom
    path "*profile_taxonomy.txt", emit: taxonomy
    path "*mqc.json", emit: mqc
    path "versions.yml", emit: versions

    script:
    prefix = task.ext.prefix ?: "${meta.id}"
    host_lineage_param = host_lineage ? "--host_lineage $host_lineage" : ""
    filtering = params.sourmash_strict_filtering ? "-f" : "" 
    """
    parse_sourmash_results_for_qiime.py $gather -n $prefix -l $sketch_log $filtering $host_lineage_param
    biom convert -i ${prefix}_absabun_parsed_profile.txt -o ${prefix}_absabun_profile.biom --table-type="OTU table" --to-json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        biom: \$(biom --version | sed 's/biom, version //')
    END_VERSIONS
    """
}

