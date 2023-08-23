/*
    Diversity indices with QIIME2
 */

include { QIIME_FILTER_SINGLETON_SAMPLE as REFMERGE_FILTER_SINGLETON } from '../../modules/nf-core/qiime/filter_singleton_sample/main'
include { REFMERGE_TAXAMERGE                                         } from '../../modules/local/refmerge/taxamerge/main'
include { REFMERGE_MERGEMETA                                         } from '../../modules/local/refmerge/mergemeta/main'
include { QIIME_ALPHARAREFACTION as REFMERGE_ALPHARAREFACTION        } from '../../modules/nf-core/qiime/alpha_rarefaction/main'
include { QIIME_DIVERSITYCORE as REFMERGE_DIVERSITYCORE              } from '../../modules/nf-core/qiime/diversitycore/main'
include { QIIME_ALPHADIVERSITY as REFMERGE_ALPHADIVERSITY            } from '../../modules/nf-core/qiime/alphadiversity/main'
include { QIIME_BETADIVERSITY as REFMERGE_BETADIVERSITY              } from '../../modules/nf-core/qiime/betadiversity/main'
include { QIIME_BETAPLOT as REFMERGE_BETAPLOT                        } from '../../modules/nf-core/qiime/betaplot/main' addParams(
    diversity_fileoutput: true
)
include { QIIME_ALPHAPLOT as REFMERGE_ALPHAPLOT                      } from '../../modules/nf-core/qiime/alphaplot/main' addParams(
    diversity_fileoutput: true
)

workflow REFMERGE_DIVERSITY {
    take:
    user_table
    user_taxonomy
    user_metadata
    ref_table
    ref_taxonomy
    ref_metadata

    main:
    ch_multiqc_files = Channel.empty()
    ch_output_file_paths = Channel.empty()

    REFMERGE_FILTER_SINGLETON( user_table, user_metadata )

    REFMERGE_TAXAMERGE( REFMERGE_FILTER_SINGLETON.out.abs_qza, user_taxonomy, ref_table, ref_taxonomy )

    REFMERGE_MERGEMETA( user_metadata, ref_metadata)

    REFMERGE_ALPHARAREFACTION ( REFMERGE_MERGEMETA.out.metadata, REFMERGE_TAXAMERGE.out.merged, REFMERGE_TAXAMERGE.out.min_total.map{it.getText()} )
    ch_output_file_paths = ch_output_file_paths.mix(
        REFMERGE_ALPHARAREFACTION.out.qzv.map{ "${params.outdir}/refmerged/alpha-rarefaction/" + it.getName() }
        )

    REFMERGE_DIVERSITYCORE ( REFMERGE_TAXAMERGE.out.merged, REFMERGE_TAXAMERGE.out.min_total.map{it.getText()}, REFMERGE_MERGEMETA.out.metadata.collect() )
    ch_output_file_paths = ch_output_file_paths.mix(
        REFMERGE_DIVERSITYCORE.out.qzv.flatten().map{ "${params.outdir}/refmerged/diversity_core/" + it.getName() }
        )

    REFMERGE_ALPHADIVERSITY ( REFMERGE_DIVERSITYCORE.out.vector.flatten(), REFMERGE_MERGEMETA.out.metadata.collect() )
    ch_output_file_paths = ch_output_file_paths.mix(
        REFMERGE_ALPHADIVERSITY.out.qzv.flatten().map{ "${params.outdir}/refmerged/alpha_diversity/" + it.getName() }
        )

    REFMERGE_BETADIVERSITY ( REFMERGE_DIVERSITYCORE.out.distance.flatten(), REFMERGE_MERGEMETA.out.metadata.collect() )
    ch_output_file_paths = ch_output_file_paths.mix(
        REFMERGE_BETADIVERSITY.out.qzv.flatten().map{ "${params.outdir}/refmerged/beta_diversity/" + it.getName() }
        )

    REFMERGE_ALPHAPLOT ( REFMERGE_MERGEMETA.out.metadata, REFMERGE_ALPHADIVERSITY.out.alphadiversity_tsv.collect().ifEmpty([]), REFMERGE_ALPHARAREFACTION.out.rarefaction_csv.collect().ifEmpty([]) )
    ch_multiqc_files = ch_multiqc_files.mix( REFMERGE_ALPHAPLOT.out.mqc_plot.collect() )

    REFMERGE_BETAPLOT ( REFMERGE_MERGEMETA.out.metadata, REFMERGE_BETADIVERSITY.out.tsv.collect() )
    ch_multiqc_files = ch_multiqc_files.mix( REFMERGE_BETAPLOT.out.report.collect() )
 
    emit:
    mqc = ch_multiqc_files
    output_paths = ch_output_file_paths
}
