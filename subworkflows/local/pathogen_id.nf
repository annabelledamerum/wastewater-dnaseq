//
// ID pathogens of interest to LACDPH
//

include { BWA_ALIGN as BWA_ALIGN_PATHDB        } from '../../modules/local/bwa_align'
include { PICARD_MARKDUPLICATES                } from '../../modules/local/picard/markduplicates'
include { SAMTOOLS_COLLECT_STATS               } from '../../modules/local/samtools_stats'
include { PATHOGEN_COVERAGE                    } from '../../modules/local/pathogen_coverage_stats.nf'
include { PATHOGEN_ID                          } from '../../modules/local/pathogen_id.nf'

workflow PATHOGEN_ID {
    take: 
    reads

    main:
    ch_versions             = Channel.empty()
    ch_multiqc_files        = Channel.empty()
    ch_output_file_paths    = Channel.empty()

    // prepare database files
    //params.pathogens_db
    pathogen_db_index = Channel.fromPath(params.pathogens_db, checkIfExists:true) 
    pathogen_db_path = params.pathogens_db.replaceAll(/\/*$/,"")
    pathogen_fasta = Channel.fromPath("${pathogen_db_path}/pathogen_reference.fasta", checkIfExists:true)
    pathogen_metadata = Channel.fromPath("${pathogen_db_path}/lacdph_pathogens_v1_20241024_metadata.txt", checkIfExists:true)
    
    // samplesheet = Channel
    //     .fromPath(params.design, checkIfExists: true)
    //     .collect()

    // align sample reads to pathogen database
    BWA_ALIGN_PATHDB(pathogen_db_index.collect(), reads)
    ch_bwa_bam_output = ch_bwa_bam_output.mix(
        BWA_ALIGN_PATHDB.out.bwa_bam
    )
    ch_versions = ch_versions.mix( BWA_ALIGN_PATHDB.out.versions )

    // remove duplicate reads from bam
    PICARD_MARKDUPLICATES(ch_bwa_bam_output, pathogen_fasta)
    ch_versions = ch_versions.mix( PICARD_MARKDUPLICATES.out.versions )

    // calculate various statistical summary files with samtools
    SAMTOOLS_COLLECT_STATS( PICARD_MARKDUPLICATES.out.mkdup_bam )
    ch_versions = ch_versions.mix( SAMTOOLS_COLLECT_STATS.out.versions )

    // summarize coverage and output results
    PATHOGEN_COVERAGE ( SAMTOOLS_COLLECT_STATS.out.coverage.collect{ it[1] }, pathogen_metadata )
    ch_output_file_paths = ch_output_file_paths.mix(
        PATHOGEN_COVERAGE.out.cov_metrics.map{ "${params.outdir}/pathogen/" + it.getName() }
    )
    // draw results plot
    PATHOGEN_RESULTS( PATHOGEN_COVERAGE.out.cov_metrics.collect{ it[1] } )
    ch_output_file_paths = ch_output_file_paths.mix(
    PATHOGEN_RESULTS.out.pathogen_heatmap.map{ "${params.outdir}/pathogen/" + it.getName() }
    )
    

    emit:
    versions         = ch_versions
    multiqc_files    = ch_multiqc_files
    output_paths     = ch_output_file_paths
    pathogen_heatmap = PATHOGEN_RESULTS.out.pathogen_heatmap
}






