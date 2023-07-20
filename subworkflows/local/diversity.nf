//
// Run profiling
//

include { QIIME_IMPORT                                  } from '../../modules/nf-core/qiime/import/main'
include { QIIME_DATAMERGE                               } from '../../modules/nf-core/qiime/datamerge/main'
include { QIIME_METADATAFILTER                          } from '../../modules/nf-core/qiime/metadatafilter/main'
include { QIIME_ALPHARAREFACTION                        } from '../../modules/nf-core/qiime/alpha_rarefaction/main'
include { QIIME_DIVERSITYCORE                           } from '../../modules/nf-core/qiime/diversitycore/main'
include { QIIME_BARPLOT                                 } from '../../modules/nf-core/qiime/barplot/main'
include { QIIME_HEATMAP                                 } from '../../modules/nf-core/qiime/heatmap/main'
include { QIIME_ALPHADIVERSITY                          } from '../../modules/nf-core/qiime/alphadiversity/main'
include { QIIME_BETADIVERSITY                           } from '../../modules/nf-core/qiime/betadiversity/main'
include { QIIME_BETAPLOT                                } from '../../modules/nf-core/qiime/betaplot/main'
include { QIIME_ALPHAPLOT                               } from '../../modules/nf-core/qiime/alphaplot/main'

workflow DIVERSITY {
    take:
    qiime_profiles // [ [ meta ], relative counts file, absolute counts file ]
    qiime_taxonomy // 
    qiime_readcounts
    groups // group_metadata.csv

    main:
    ch_versions             = Channel.empty()
    ch_multiqc_files        = Channel.empty()
    ch_output_paths         = Channel.empty()

    QIIME_IMPORT ( qiime_profiles )

    QIIME_DATAMERGE( QIIME_IMPORT.out.relabun_merged_qza.collect(), QIIME_IMPORT.out.absabun_merged_qza.collect(), qiime_readcounts )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_DATAMERGE.out.filtered_samples_abscounts.map{ "${params.outdir}/qiime_mergeddata/" + it.getName() },
        QIIME_DATAMERGE.out.filtered_samples_relcounts.map{ "${params.outdir}/qiime_mergeddata/" + it.getName() }
        )
 
    QIIME_BARPLOT( QIIME_DATAMERGE.out.filtered_abs_qzamerged, qiime_taxonomy.collect())
    ch_versions     = ch_versions.mix( QIIME_BARPLOT.out.versions )
    ch_multiqc_files = ch_multiqc_files.mix( QIIME_BARPLOT.out.barplot_composition.collect().ifEmpty([]) )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_BARPLOT.out.qzv.map{ "${params.outdir}/qiime_composition_barplot/" + it.getName() }
        )

    QIIME_METADATAFILTER( groups, QIIME_DATAMERGE.out.samples_filtered )
        
    QIIME_HEATMAP( QIIME_DATAMERGE.out.filtered_samples_relcounts, QIIME_METADATAFILTER.out.filtered_metadata )
    ch_multiqc_files = ch_multiqc_files.mix( QIIME_HEATMAP.out.taxo_heatmap.collect().ifEmpty([]) ) 

    QIIME_ALPHARAREFACTION( QIIME_METADATAFILTER.out.filtered_metadata, QIIME_DATAMERGE.out.filtered_abs_qzamerged, QIIME_DATAMERGE.out.readcount_maxsubset )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_ALPHARAREFACTION.out.alpha_rarefaction_qzv.map{ "${params.outdir}/qiime_alpha_rarefaction/" + it.getName() }
        )

    QIIME_DIVERSITYCORE( QIIME_DATAMERGE.out.filtered_abs_qzamerged, QIIME_DATAMERGE.out.readcount_maxsubset, QIIME_METADATAFILTER.out.filtered_metadata )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_DIVERSITYCORE.out.qzv.flatten().map{ "${params.outdir}/qiime_diversity/diversity_core/" + it.getName() }
        )

    QIIME_ALPHADIVERSITY( QIIME_DIVERSITYCORE.out.vector.flatten(), QIIME_METADATAFILTER.out.filtered_metadata.collect() )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_ALPHADIVERSITY.out.qzv.flatten().map{ "${params.outdir}/qiime_diversity/alpha_diversity/" + it.getName() }
        )

    QIIME_BETADIVERSITY ( QIIME_DIVERSITYCORE.out.distance.flatten(), QIIME_METADATAFILTER.out.filtered_metadata.collect() )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_BETADIVERSITY.out.qzv.flatten().map{ "${params.outdir}/qiime_diversity/beta_diversity/" + it.getName() }
        )

    QIIME_ALPHAPLOT( QIIME_METADATAFILTER.out.filtered_metadata, QIIME_ALPHADIVERSITY.out.alphadiversity_tsv.collect().ifEmpty([]), QIIME_ALPHARAREFACTION.out.rarefaction_csv.collect().ifEmpty([]) )
    ch_multiqc_files = ch_multiqc_files.mix( QIIME_ALPHAPLOT.out.mqc_plot.collect().ifEmpty([]) )

    QIIME_BETAPLOT( QIIME_METADATAFILTER.out.filtered_metadata, QIIME_BETADIVERSITY.out.tsv.collect() )
    ch_multiqc_files = ch_multiqc_files.mix( QIIME_BETAPLOT.out.report.collect().ifEmpty([]) )

    emit:
    versions        = ch_versions          // channel: [ versions.yml ]
    mqc             = ch_multiqc_files
    output_paths    = ch_output_file_paths
}
