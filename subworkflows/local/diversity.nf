//
// Run profiling
//

include { QIIME_IMPORT                                  } from '../../modules/nf-core/qiime/import/main'
include { QIIME_DATAMERGE                               } from '../../modules/nf-core/qiime/datamerge/main'
include { QIIME_METADATAFILTER                          } from '../../modules/nf-core/qiime/metadatafilter/main'
include { QIIME_FILTER_SINGLETON_SAMPLE                 } from '../../modules/nf-core/qiime/filter_singleton_sample/main'
include { QIIME_ALPHARAREFACTION                        } from '../../modules/nf-core/qiime/alpha_rarefaction/main'
include { QIIME_DIVERSITYCORE                           } from '../../modules/nf-core/qiime/diversitycore/main'
include { QIIME_BARPLOT                                 } from '../../modules/nf-core/qiime/barplot/main'
include { QIIME_HEATMAP                                 } from '../../modules/nf-core/qiime/heatmap/main'
include { QIIME_ALPHADIVERSITY                          } from '../../modules/nf-core/qiime/alphadiversity/main'
include { QIIME_BETADIVERSITY                           } from '../../modules/nf-core/qiime/betadiversity/main'
include { QIIME_BETAGROUPCOMPARE                        } from '../../modules/nf-core/qiime/beta_groupcompare/main'
include { QIIME_BETAPLOT                                } from '../../modules/nf-core/qiime/betaplot/main'
include { QIIME_ALPHAPLOT                               } from '../../modules/nf-core/qiime/alphaplot/main'

workflow DIVERSITY {
    take:
    qiime_profiles // [ [ meta ], absolute counts file ]
    qiime_taxonomy // 
    groups // group_metadata.csv

    main:
    ch_versions             = Channel.empty()
    ch_multiqc_files        = Channel.empty()
    ch_output_file_paths    = Channel.empty()

    QIIME_IMPORT ( qiime_profiles )
    ch_versions = ch_versions.mix( QIIME_IMPORT.out.versions )

    QIIME_DATAMERGE(  QIIME_IMPORT.out.absabun_qza.collect(), qiime_taxonomy.collect() )
    ch_versions = ch_versions.mix( QIIME_DATAMERGE.out.versions )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_DATAMERGE.out.filtered_counts_collapsed_tsv.map{ "${params.outdir}/qiime_mergeddata/" + it.getName() }
        )
 
    QIIME_BARPLOT( QIIME_DATAMERGE.out.filtered_counts_qza, QIIME_DATAMERGE.out.taxonomy_qza )
    ch_versions = ch_versions.mix( QIIME_BARPLOT.out.versions )
    ch_multiqc_files = ch_multiqc_files.mix( QIIME_BARPLOT.out.barplot_composition.collect().ifEmpty([]) )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_BARPLOT.out.qzv.map{ "${params.outdir}/qiime_composition_barplot/" + it.getName() }
        )

    QIIME_METADATAFILTER( groups, QIIME_DATAMERGE.out.filtered_counts_collapsed_tsv )

    QIIME_FILTER_SINGLETON_SAMPLE( QIIME_DATAMERGE.out.filtered_counts_collapsed_qza, QIIME_METADATAFILTER.out.filtered_metadata )
    ch_versions = ch_versions.mix( QIIME_FILTER_SINGLETON_SAMPLE.out.versions )
        
    QIIME_HEATMAP( QIIME_FILTER_SINGLETON_SAMPLE.out.rel_tsv, QIIME_METADATAFILTER.out.filtered_metadata )
    ch_multiqc_files = ch_multiqc_files.mix( QIIME_HEATMAP.out.taxo_heatmap.collect().ifEmpty([]) ) 

    QIIME_ALPHARAREFACTION( QIIME_METADATAFILTER.out.filtered_metadata, QIIME_FILTER_SINGLETON_SAMPLE.out.abs_qza, QIIME_METADATAFILTER.out.min_total )
    ch_versions = ch_versions.mix( QIIME_ALPHARAREFACTION.out.versions )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_ALPHARAREFACTION.out.qzv.map{ "${params.outdir}/qiime_alpha_rarefaction/" + it.getName() }
        )

    QIIME_DIVERSITYCORE( QIIME_FILTER_SINGLETON_SAMPLE.out.abs_qza, QIIME_METADATAFILTER.out.min_total, QIIME_METADATAFILTER.out.filtered_metadata )
    ch_versions = ch_versions.mix( QIIME_DIVERSITYCORE.out.versions )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_DIVERSITYCORE.out.qzv.flatten().map{ "${params.outdir}/qiime_diversity/diversity_core/" + it.getName() }
        )

    QIIME_ALPHADIVERSITY( QIIME_DIVERSITYCORE.out.vector.flatten(), QIIME_METADATAFILTER.out.filtered_metadata.collect() )
    ch_versions = ch_versions.mix( QIIME_ALPHADIVERSITY.out.versions )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_ALPHADIVERSITY.out.qzv.flatten().map{ "${params.outdir}/qiime_diversity/alpha_diversity/" + it.getName() }
        ) 

    QIIME_BETADIVERSITY( QIIME_DIVERSITYCORE.out.pcoa.flatten(), QIIME_METADATAFILTER.out.filtered_metadata.collect() )
    ch_versions = ch_versions.mix( QIIME_BETADIVERSITY.out.versions )

    QIIME_BETAGROUPCOMPARE ( QIIME_DIVERSITYCORE.out.distance.flatten(), QIIME_METADATAFILTER.out.filtered_metadata.collect() )
    ch_versions = ch_versions.mix( QIIME_BETAGROUPCOMPARE.out.versions )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_BETAGROUPCOMPARE.out.qzv.flatten().map{ "${params.outdir}/qiime_diversity/beta_group_comparison/" + it.getName() }
        )

    QIIME_ALPHAPLOT( QIIME_METADATAFILTER.out.filtered_metadata, QIIME_ALPHADIVERSITY.out.alphadiversity_tsv.collect().ifEmpty([]), QIIME_ALPHARAREFACTION.out.rarefaction_csv.collect().ifEmpty([]) )
    ch_multiqc_files = ch_multiqc_files.mix( QIIME_ALPHAPLOT.out.mqc_plot.collect().ifEmpty([]) )

    QIIME_BETAPLOT( QIIME_METADATAFILTER.out.filtered_metadata.collect(), QIIME_BETADIVERSITY.out.tsv.collect() )
    ch_multiqc_files = ch_multiqc_files.mix( QIIME_BETAPLOT.out.report.collect().ifEmpty([]) )

    emit:
    versions        = ch_versions          // channel: [ versions.yml ]
    mqc             = ch_multiqc_files
    output_paths    = ch_output_file_paths
    tables          = QIIME_DATAMERGE.out.filtered_counts_qza
    taxonomy        = QIIME_DATAMERGE.out.taxonomy_qza
    metadata        = QIIME_METADATAFILTER.out.ref_comp_metadata
}
