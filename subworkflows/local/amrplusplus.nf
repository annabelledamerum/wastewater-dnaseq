//
// Run amr plus plus
//

include { BWA_ALIGN                                  } from '../../modules/local/bwa_align'
include { RESISTOME_RUN                              } from '../../modules/local/resistome_run'
include { RESISTOME_RESULTS                          } from '../../modules/local/resistome_results' 

workflow AMRPLUSPLUS {
    take:
    reads // [ [ meta ], readfiles ]

    main:
    ch_versions             = Channel.empty()
    ch_bwa_bam_output       = Channel.empty()
    ch_multiqc_files        = Channel.empty()

    BWA_ALIGN(params.amr_index_files, params.amr_index_name, reads)
    ch_bwa_bam_output = ch_bwa_bam_output.mix(
        BWA_ALIGN.out.bwa_bam
    )
    ch_versions = ch_versions.mix( BWA_ALIGN.out.versions )
    RESISTOME_RUN(BWA_ALIGN.out.bwa_bam, params.amr_fasta, params.amr_annotation)
    RESISTOME_RESULTS(RESISTOME_RUN.out.resistome_counts.collect())
    ch_multiqc_files = ch_multiqc_files.mix(RESISTOME_RESULTS.out.analytic_matrix)

    emit:
    versions      = ch_versions          // channel: [ versions.yml ]
    bwa_bam       = ch_bwa_bam_output
    multiqc_files = ch_multiqc_files
}
