//
// Run amr plus plus
//

include { BWA_ALIGN                                  } from '../../modules/local/bwa_align'
include { RESISTOME_RUN                              } from '../../modules/local/resistome_run'
include { RESISTOME_RESULTS                          } from '../../modules/local/resistome_results' 
include { RAREFACTION_RUN                            } from '../../modules/local/rarefaction_run'

workflow AMRPLUSPLUS {
    take:
    reads // [ [ meta ], readfiles ]

    main:
    ch_versions             = Channel.empty()
    ch_bwa_bam_output    = Channel.empty()

    BWA_ALIGN(params.amr_index_files, params.amr_index_name, reads)
    RESISTOME_RUN(BWA_ALIGN.out.bwa_bam, params.amr_fasta, params.amr_annotation)
    RESISTOME_RESULTS(RESISTOME_RUN.out.resistome_counts.collect())
    RAREFACTION_RUN(BWA_ALIGN.out.bwa_bam, params.amr_fasta, params.amr_annotation)
    ch_versions = ch_versions.mix( BWA_ALIGN.out.versions )
    ch_bwa_bam_output = ch_bwa_bam_output.mix(
        BWA_ALIGN.out.bwa_bam
    )

    emit:
    versions        = ch_versions          // channel: [ versions.yml ]
    bwa_bam    = ch_bwa_bam_output
}
