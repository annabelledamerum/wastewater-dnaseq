process BIOMPREP_FORQIIME {
    label 'process_medium'
    
    conda "bioconda::biom-format=2.1.7=py27_0"
    container 'quay.io/biocontainers/biom-format:2.1.7--py27_0'
    
    input:
    tuple val(meta), path(mpa_profile)

    output:
    tuple val(meta), path('*parsed_mpaprofile.biom')   , emit: mpa_biomprofile
    path('*profile_taxonomy.txt')    , emit: taxonomy
    path "versions.yml"             , emit: versions
    

    script:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    head -n 5 $mpa_profile > ${prefix}_infotext.txt
    sed '1,5d' $mpa_profile | sed 's/#//g' > ${prefix}_profile.txt
    metaphlan_parse.py -i ${prefix}_infotext.txt -t ${prefix}_profile.txt --label "${prefix}"
    biom convert -i ${prefix}_parsed_mpaprofile.txt -o ${prefix}_parsed_mpaprofile.biom --table-type="OTU table" --to-json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        biom: \$(biom --version | sed 's/biom, version //')
    END_VERSIONS
    """
}
