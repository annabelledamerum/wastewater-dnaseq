//
// Run classify
//

include { SOURMASH_SKETCH                               } from '../../modules/local/sourmash/sketch/main'
include { SOURMASH_GATHER                               } from '../../modules/local/sourmash/gather/main'
include { SOURMASH_QIIMEPREP                            } from '../../modules/local/sourmash/qiimeprep/main'
include { MINIMAP2_INDEX                                } from '../../modules/local/minimap2/index/main.nf'
include { MINIMAP2_ALIGN                                } from '../../modules/nf-core/minimap2/align/main.nf'


workflow CLASSIFY {
    take:
    reads // [ [ meta ], [ reads ] ]
    databases // [ [ meta ], path ]
    genomes // [ [ meta ], path ]

    main:
    ch_versions             = Channel.empty()
    ch_multiqc_files        = Channel.empty()
    ch_raw_classifications  = Channel.empty()
    ch_raw_profiles         = Channel.empty()
    ch_qiime_profiles       = Channel.empty()
    ch_taxonomy             = Channel.empty()
    
    //COMBINE READS WITH POSSIBLE DATABASES
    // e.g. output [DUMP: reads_plus_db] [['id':'2612', 'run_accession':'combined', 'instrument_platform':'ILLUMINA', 'single_end':1], <reads_path>/2612.merged.fastq.gz, ['tool':'malt', 'db_name':'mal95', 'db_params':'"-id 90"'], <db_path>/malt90]
    ch_input_for_profiling = reads
            .map {
                meta, reads ->
                    [meta, reads]
            }//Not sure if this mapping is needed, will test later
            .combine(databases)
            .combine(genomes)


    ch_input_for_sourmash =  ch_input_for_profiling
                                .filter{
                                    if (it[0].is_fasta) log.warn "[Zymo-Research/aladdin-shotgun] Sourmash currently does not accept FASTA files as input. Skipping Sourmash for sample ${it[0].id}."
                                    !it[0].is_fasta
                                }
                                .multiMap {
                                    it ->
                                        reads: [ it[0] + it[2], it[1] ]
                                        db: it[3]
                                        genomes: it[4]
                                }
    host_lineage = params.host_lineage ? Channel.fromPath(params.host_lineage) : Channel.empty()

    if (params.sourmash_trim_low_abund) {
        KHMER_TRIM_LOW_ABUND ( ch_input_for_sourmash.reads )
        ch_input_for_sourmash_sketch = KHMER_TRIM_LOW_ABUND.out.reads
        ch_versions = ch_versions.mix( KHMER_TRIM_LOW_ABUND.out.versions.first() )
    } else {
        ch_input_for_sourmash_sketch = ch_input_for_sourmash.reads
    }

    SOURMASH_SKETCH ( ch_input_for_sourmash_sketch )
    ch_versions = ch_versions.mix( SOURMASH_SKETCH.out.versions.first() )
    SOURMASH_GATHER ( SOURMASH_SKETCH.out.sketch, ch_input_for_sourmash.db )
    ch_versions = ch_versions.mix( SOURMASH_GATHER.out.versions.first() )
    SOURMASH_GATHER.out.gather
        .join( SOURMASH_SKETCH.out.sketch )
        .map { [it[0], it[1], it[3]] }
        .set { qiime2_input }
    SOURMASH_QIIMEPREP ( qiime2_input, host_lineage.collect().ifEmpty([]) )
    ch_versions = ch_versions.mix( SOURMASH_QIIMEPREP.out.versions.first() )
    ch_multiqc_files = ch_multiqc_files.mix( SOURMASH_QIIMEPREP.out.mqc.collect().ifEmpty([]) )
    ch_qiime_profiles = ch_qiime_profiles.mix( SOURMASH_QIIMEPREP.out.biom )
    ch_taxonomy = ch_taxonomy.mix( SOURMASH_QIIMEPREP.out.taxonomy )

    //// add in minimap2 primary alignment
    // create index from: 
    // accession list == SOURMASH_QIIMEPREP.out.accessions
    // genomes == ch_input_for_sourmash.genomes
    MINIMAP2_INDEX ( SOURMASH_QIIMEPREP.out.accessions, ch_input_for_sourmash.genomes )
    ch_versions = ch_versions.mix( MINIMAP2_INDEX.out.versions.first() )
    MINIMAP2_ALIGN ( ch_input_for_sourmash_sketch, ch_minimap2_indexes )

    //// add in primary alignment clustering

    //// add in minimap2 secondary alignment


    // Find samples that failed profiling and output a warning
    ch_qiime_profiles
        .map { [it[0].id, it[1]] }
        .set { ch_profiling_pass }
    reads
        .map { [it[0].id, it[1]] }
        .join(ch_profiling_pass, remainder:true)
        .filter { !it[2] }
        .map { it[0] }
        .collect()
        .map {
            "The following samples failed taxonomy profiling steps or didn't have any identifiable microbe:\n${it.join("; ")}\nPlease contact us if you want to troubleshoot them."
        }
        .set {ch_warning_message }
    ch_warning_message
        .subscribe {
            log.error "$it"
            params.ignore_failed_samples ? { log.warn "Ignoring failed samples and continue!" } : System.exit(1)
        }


    emit:
    classifications = ch_raw_classifications
    profiles        = ch_raw_profiles    // channel: [ val(meta), [ reads ] ] - should be text files or biom
    qiime_profiles  = ch_qiime_profiles  // channel: [ val(meta), absolute abundance profiles ]
    qiime_taxonomy  = ch_taxonomy
    versions        = ch_versions
    motus_version   = params.profiler == "motus" ? MOTUS_PROFILE.out.versions.first() : Channel.empty()
    mqc             = ch_multiqc_files
    warning         = ch_warning_message
}