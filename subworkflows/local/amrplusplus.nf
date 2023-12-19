//
// Run amr plus plus
//

include { BWA_ALIGN                                  } from '../../modules/local/bwa_align'
include { RESISTOME_RUN                              } from '../../modules/local/resistome_run'
include { RESISTOME_RESULTS                          } from '../../modules/local/resistome_results' 
include { RESISTOME_SNPVERIFY                        } from '../../modules/local/resistome_snpverify'
include { RESISTOME_SNPRESULTS                       } from '../../modules/local/resistome_snpresults'


workflow AMRPLUSPLUS {
    take:
    reads // [ [ meta ], readfiles ]

    main:
    ch_versions             = Channel.empty()
    ch_bwa_bam_output       = Channel.empty()
    ch_multiqc_files        = Channel.empty()

    snp_config = Channel.from(file(params.amr_SNP_config, checkIfExists: true))
    ch_snpverify_dataset = Channel.from([file(params.amr_SNP_verification_database, checkIfExists: true)])

    BWA_ALIGN(params.amr_index_files, params.amr_index_name, reads)
    ch_bwa_bam_output = ch_bwa_bam_output.mix(
        BWA_ALIGN.out.bwa_bam
    )
    ch_versions = ch_versions.mix( BWA_ALIGN.out.versions )
    RESISTOME_RUN(BWA_ALIGN.out.bwa_bam, params.amr_fasta, params.amr_annotation)
    RESISTOME_RESULTS(RESISTOME_RUN.out.class_resistome_counts.collect(), RESISTOME_RUN.out.gene_resistome_counts.collect(), RESISTOME_RUN.out.mechanism_resistome_counts.collect(), RESISTOME_RUN.out.group_resistome_counts.collect() )
    ch_multiqc_files = ch_multiqc_files.mix(RESISTOME_RESULTS.out.class_resistome_count_matrix, RESISTOME_RESULTS.out.top20_genelevel_resistome)
    RESISTOME_SNPVERIFY( BWA_ALIGN.out.bwa_bam, RESISTOME_RESULTS.out.gene_count_matrix.collect(), snp_config.collect(), ch_snpverify_dataset.collect())   
    RESISTOME_SNPRESULTS( RESISTOME_SNPVERIFY.out.snp_counts.collect() )

    emit:
    versions      = ch_versions          // channel: [ versions.yml ]
    bwa_bam       = ch_bwa_bam_output
    multiqc_files = ch_multiqc_files
}
