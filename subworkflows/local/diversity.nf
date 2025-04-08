//
// Run profiling
//


/// Subworkflow
include { QIIME2_EXPORT                                } from '../../subworkflows/local/qiime2_export'
include { QIIME2_DIVERSITY                             } from '../../subworkflows/local/qiime2_diversity'

// Modules
include { QIIME_IMPORT                                  } from '../../modules/nf-core/qiime/import/main'
include { QIIME_DATAMERGE                               } from '../../modules/nf-core/qiime/datamerge/main'
include { QIIME_METADATAFILTER                          } from '../../modules/nf-core/qiime/metadatafilter/main'
include { QIIME_FILTER_SINGLETON_SAMPLE                 } from '../../modules/nf-core/qiime/filter_singleton_sample/main'
include { QIIME_ALPHARAREFACTION                        } from '../../modules/nf-core/qiime/alpha_rarefaction/main'
include { QIIME_DIVERSITYCORE                           } from '../../modules/nf-core/qiime/diversitycore/main'
include { QIIME_BARPLOT                                 } from '../../modules/nf-core/qiime/barplot/main'
include { GROUP_COMPOSITION                             } from '../../modules/local/group_composition'
include { HEATMAP_INPUT                                 } from '../../modules/local/heatmap_input'
include { QIIME_ALPHADIVERSITY                          } from '../../modules/nf-core/qiime/alphadiversity/main'
include { QIIME_BETAGROUPCOMPARE                        } from '../../modules/nf-core/qiime/beta_groupcompare/main'
include { QIIME_ANCOMBC                                 } from '../../modules/nf-core/qiime/ancombc/main'
include { QIIME_PARSEANCOMBC                            } from '../../modules/nf-core/qiime/parse_ancombc/main'
include { QIIME_PLOT_MULTIQC                            } from '../../modules/nf-core/qiime/plot_multiqc/main'

workflow DIVERSITY {
    take:
    qiime_profiles // [ [ meta ], absolute counts file ]
    qiime_taxonomy // 
    groups // group_metadata.csv
    tax_agglom_min
    tax_agglom_max

    main:
    ch_versions          = Channel.empty()
    ch_multiqc_files     = Channel.empty()
    ch_output_file_paths = Channel.empty()
    ch_excel             = Channel.empty()
    ch_warning_message   = Channel.empty()

    QIIME_IMPORT ( qiime_profiles )
    ch_versions = ch_versions.mix( QIIME_IMPORT.out.versions )

    QIIME_DATAMERGE( QIIME_IMPORT.out.absabun_qza.collect(), qiime_taxonomy.collect() )
    ch_versions = ch_versions.mix( QIIME_DATAMERGE.out.versions )
    
    QIIME2_EXPORT( QIIME_DATAMERGE.out.filtered_counts_qza, QIIME_DATAMERGE.out.taxonomy_qza, QIIME_DATAMERGE.out.taxonomy_tsv, tax_agglom_min, tax_agglom_max )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME2_EXPORT.out.abs_taxa_levels.flatten().map{ "${params.outdir}/qiime_export/" + it.getName() }
        )

    QIIME_BARPLOT( QIIME_DATAMERGE.out.filtered_counts_qza, QIIME_DATAMERGE.out.taxonomy_qza, groups )
    ch_versions = ch_versions.mix( QIIME_BARPLOT.out.versions )
    ch_multiqc_files = ch_multiqc_files.mix( QIIME_BARPLOT.out.barplot_composition.collect() )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_BARPLOT.out.qzv.map{ "${params.outdir}/qiime_composition_barplot/" + it.getName() }
        )

    if (params.group_of_interest != 'NONE') {
    	ch_excel = Channel.fromPath(params.groupinterest[params.group_of_interest].excel_path, checkIfExists: true)
        GROUP_COMPOSITION( ch_excel, QIIME_BARPLOT.out.barplot_composition.collect() )
        ch_multiqc_files = ch_multiqc_files.mix( GROUP_COMPOSITION.out.compcsv.collect() )
        ch_output_file_paths = ch_output_file_paths.mix(
            GROUP_COMPOSITION.out.search_results.map { "${params.outdir}/groups_of_interest/" + it.getName() }
            )
    }

    QIIME2_DIVERSITY( QIIME2_EXPORT.out.lvl7_qza, QIIME2_EXPORT.out.lvl7_tsv, groups ) 
    ch_multiqc_files = ch_multiqc_files.mix( QIIME2_DIVERSITY.out.mqc )
    ch_output_file_paths = ch_output_file_paths.mix( QIIME2_DIVERSITY.out.output_paths )
    ch_versions = ch_versions.mix( QIIME2_DIVERSITY.out.versions )
    
        
    HEATMAP_INPUT( QIIME_BARPLOT.out.barplot_composition.collect(), QIIME2_DIVERSITY.out.filtered_metadata, params.top_taxa )
    ch_multiqc_files = ch_multiqc_files.mix( HEATMAP_INPUT.out.taxo_heatmap.collect()) 

    QIIME_ANCOMBC ( QIIME2_DIVERSITY.out.filtered_abs_qza, QIIME2_DIVERSITY.out.filtered_metadata ) 
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_ANCOMBC.out.ancombc.map{ "${params.outdir}/qiime_ancombc/" + it.getName() }
        )
    ch_output_file_paths = ch_output_file_paths.mix(
        QIIME_ANCOMBC.out.group_ancombc_csv.flatten().map{ "${params.outdir}/qiime_ancombc/" + it.getName() } 
        )

    QIIME_PARSEANCOMBC ( QIIME_ANCOMBC.out.ancombc_mqc.collect(), QIIME_ANCOMBC.out.reference_group )
    ch_multiqc_files = ch_multiqc_files.mix( QIIME_PARSEANCOMBC.out.ancombc_plot.collect() )

    emit:
    versions     = ch_versions          // channel: [ versions.yml ]
    mqc          = ch_multiqc_files
    output_paths = ch_output_file_paths
    tables       = QIIME_DATAMERGE.out.filtered_counts_qza
    taxonomy     = QIIME_DATAMERGE.out.taxonomy_qza
    metadata     = QIIME2_DIVERSITY.out.ref_metadata
    warning      = ch_warning_message
}
