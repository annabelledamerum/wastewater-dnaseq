/*
    Diversity indices with QIIME2
 */

include { QIIME_ALPHARAREFACTION as REFMERGE_ALPHARAREFACTION } from '../../modules/nf-core/qiime/alpha_rarefaction/main'
include { QIIME_DIVERSITYCORE as REFMERGE_DIVERSITYCORE } from '../../modules/nf-core/qiime/diversitycore/main'
include { QIIME_ALPHADIVERSITY as REFMERGE_ALPHADIVERSITY } from '../../modules/nf-core/qiime/alphadiversity/main'
include { QIIME_BETADIVERSITY as REFMERGE_BETADIVERSITY } from '../../modules/nf-core/qiime/betadiversity/main'
//include { QIIME2_DIVERSITY_ADONIS as REFMERGE_DIVERSITY_ADONIS } from '../../modules/local/qiime2_diversity_adonis'
//include { QIIME2_DIVERSITY_BETAORD as REFMERGE_DIVERSITY_BETAORD } from '../../modules/local/qiime2_diversity_betaord'
// include { REFMERGE_PLOT_DIVERSITY_MULTIQC } from '../../modules/local/refmerge_plot_diversity_multiqc'
include { REFMERGE_BETAPLOT } from '../../modules/local/refmerge/betaplot/main'
include { REFMERGE_ALPHAPLOT } from '../../modules/local/refmerge/alphaplot/main'

workflow REFMERGE_DIVERSITY {
    take:
    ch_metadata
    ch_asv
    ch_stats
    ch_mintotal

    main:

    //Alpha-rarefaction
    REFMERGE_ALPHARAREFACTION ( ch_metadata, ch_asv, ch_mintotal )

    //Calculate diversity indices
    REFMERGE_DIVERSITYCORE ( ch_asv, ch_mintotal, ch_metadata )

    //alpha_diversity ( ch_metadata, DIVERSITY_CORE.out.qza, ch_metacolumn_all )
    REFMERGE_ALPHADIVERSITY ( REFMERGE_DIVERSITYCORE.out.vector.flatten(), ch_metadata.collect() )
    //beta_diversity ( ch_metadata, DIVERSITY_CORE.out.qza, ch_metacolumn_pairwise )
    REFMERGE_BETADIVERSITY ( REFMERGE_DIVERSITYCORE.out.distance.flatten(), ch_metadata.collect() )
    //beta_diversity_ordination ( ch_metadata, DIVERSITY_CORE.out.qza )
    //ch_metadata
        //.combine( REFMERGE_DIVERSITY_CORE.out.pcoa.flatten() )
        //.set{ ch_to_diversity_betaord }
    //REFMERGE_DIVERSITY_BETAORD ( ch_to_diversity_betaord )

    REFMERGE_BETAPLOT (
        ch_metadata.collect(),
        REFMERGE_BETADIVERSITY.out.tsv.collect(),
    )

    REFMERGE_ALPHAPLOT (
        ch_metadata.collect(),
        REFMERGE_ALPHADIVERSITY.out.alphadiversity_tsv.collect().ifEmpty([]),
        REFMERGE_ALPHARAREFACTION.out.rarefaction_csv.collect().ifEmpty([])
    )

    

emit:
//alpha_diversity_plot    = REFMERGE_ALPHADIVERSITY.out.metadata_tsv.collect().ifEmpty([])
rarefaction_plot        = REFMERGE_ALPHARAREFACTION.out.rarefaction_csv
beta_diversity          = REFMERGE_BETAPLOT.out.report.collect()
alpha_diversity         = REFMERGE_ALPHAPLOT.out.mqc_plot.collect()
alpha_rarefaction       = REFMERGE_ALPHARAREFACTION.out.qzv
diversity_core_vis      = REFMERGE_DIVERSITYCORE.out.qzv.collect().ifEmpty([])
//sample_removed_summary  = REFMERGE_DIVERSITYCORE.out.sample_removed.collect().ifEmpty([])
//betaord_vis             = REFMERGE_DIVERSITY_BETAORD.out.qzv.collect().ifEmpty([])
alpha_vis               = REFMERGE_ALPHADIVERSITY.out.qzv.collect().ifEmpty([])
beta_vis                = REFMERGE_BETADIVERSITY.out.qzv.collect().ifEmpty([])
}
