//
// Run amr plus plus
//

include { BWA_ALIGN as BWA_ALIGN_AMRDB               } from '../../modules/local/bwa_align'
include { RESISTOME_RUN                              } from '../../modules/local/resistome/resistome_run'
include { RESISTOME_RESULTS                          } from '../../modules/local/resistome/resistome_results' 
include { RESISTOME_SNPVERIFY                        } from '../../modules/local/resistome/resistome_snpverify'
include { RESISTOME_SNPRESULTS                       } from '../../modules/local/resistome/resistome_snpresults'


workflow AMRPLUSPLUS {
    take:
    reads // [ [ meta ], readfiles ]

    main:
    ch_versions             = Channel.empty()
    ch_bwa_bam_output       = Channel.empty()
    ch_multiqc_files        = Channel.empty()
    ch_output_file_paths    = Channel.empty()

    // Prepare various AMR files
    index_files = Channel.fromPath(params.amr_index_files, checkIfExists:true)
    amr_file_path = params.amr_index_files.replaceAll(/\/*$/,"")
    amr_fasta = Channel.fromPath("${amr_file_path}/megares_database_v3.00.fasta", checkIfExists:true)
    amr_annotation = Channel.fromPath("${amr_file_path}/megares_annotations_v3.00.csv", checkIfExists:true)
    snp_config = Channel.fromPath("${amr_file_path}/config.ini", checkIfExists:true)
    ch_snpverify_dataset = Channel.fromPath("${amr_file_path}/SNP_verification/*{.csv,.fasta}", checkIfExists:true)
    amr_annotation_additional = Channel.fromPath("${amr_file_path}/megares_v3.00_annotations_additional.csv", checkIfExists:true)

    BWA_ALIGN_AMRDB(index_files.collect(), reads)
    ch_bwa_bam_output = ch_bwa_bam_output.mix(
        BWA_ALIGN_AMRDB.out.bwa_bam
    )
    ch_versions = ch_versions.mix( BWA_ALIGN_AMRDB.out.versions )
    RESISTOME_RUN(BWA_ALIGN_AMRDB.out.bwa_bam, amr_fasta.collect(), amr_annotation.collect())
    RESISTOME_RESULTS(RESISTOME_RUN.out.class_resistome_counts.collect(), 
        RESISTOME_RUN.out.gene_resistome_counts.collect(), 
        RESISTOME_RUN.out.mechanism_resistome_counts.collect(), 
        RESISTOME_RUN.out.group_resistome_counts.collect(),
        BWA_ALIGN_AMRDB.out.bam_flagstats.collect() )
    RESISTOME_SNPVERIFY( BWA_ALIGN_AMRDB.out.bwa_bam, RESISTOME_RESULTS.out.gene_count_matrix.collect(), snp_config.collect(), ch_snpverify_dataset.collect())   
    RESISTOME_SNPRESULTS( RESISTOME_SNPVERIFY.out.snp_counts.collect(), BWA_ALIGN_AMRDB.out.bam_flagstats.collect(), amr_annotation_additional )
    ch_multiqc_files = ch_multiqc_files.mix(RESISTOME_RESULTS.out.class_resistome_count_matrix, RESISTOME_RESULTS.out.top20_genelevel_resistome, RESISTOME_SNPRESULTS.out.amr_matrix_pivot, RESISTOME_SNPRESULTS.out.amr_heatmap)
    ch_output_file_paths = ch_output_file_paths.mix( RESISTOME_RESULTS.out.class_count_matrix, 
                                                     RESISTOME_RESULTS.out.mechanism_count_matrix, 
                                                     RESISTOME_RESULTS.out.gene_count_matrix,
                                                     RESISTOME_SNPRESULTS.out.gene_counts_SNPverified,
                                                     RESISTOME_SNPRESULTS.out.gene_counts_SNPverified_normalized,
                                                     RESISTOME_SNPRESULTS.out.amr_matrix_pivot,
                                                     RESISTOME_SNPRESULTS.out.amr_heatmap)
    ch_output_file_paths = ch_output_file_paths.map{ "${params.outdir}/resistome_results/" + it.getName() }


    emit:
    versions      = ch_versions          // channel: [ versions.yml ]
    bwa_bam       = ch_bwa_bam_output
    output_paths  = ch_output_file_paths
    multiqc_files = ch_multiqc_files
}
