process MINIMAP2_INDEX {
    tag "$meta.id"
    label 'process_medium'
    // Note: the versions here need to match the versions used in minimap2/align
    conda "bioconda::minimap2=2.24"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/minimap2:2.24--h7132678_1' :
        'quay.io/biocontainers/minimap2:2.24--h7132678_1' }"

    input:
    tuple val(meta), path(accession_list)
    path genome_dir from ch_genome_dir

    output:
    tuple val(meta), path("${meta.id}.mmi") into ch_minimap2_indexes

    script:
    """
    mkdir -p tmp_genomes

    # Extract genome paths matching accessions
    while read acc; do
        gz_path=\$(find ${genome_dir} -type f \\( -name "\${acc}.fna.gz" -o -name "\${acc}.fasta.gz" \\) | head -n 1)
        if [ -f "\$gz_path" ]; then
            cp "\$gz_path" tmp_genomes/
        else
            echo "WARNING: Accession \$acc not found in genome directory" >&2
        fi
    done < ${accession_list}

    # Concatenate and decompress all genomes into a single file
    zcat tmp_genomes/*.gz > ${meta.id}.combined.fna

    # Create minimap2 index
    minimap2 -t ${task.cpus} -d ${meta.id}.mmi ${meta.id}.combined.fna

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        minimap2: \$(minimap2 --version 2>&1)
    END_VERSIONS
    """
}