/*
    Diversity indices with QIIME2
 */

include { REFMERGE_ALPHARAREFACTION    } from '../../modules/local/refmerge/alphararefaction/main'

include { REFMERGE_DIVERSITYCORE      } from '../../modules/local/refmerge/diversitycore/main'
//include { QIIME2_DIVERSITY_ALPHA as REFMERGE_DIVERSITY_ALPHA } from '../../modules/local/qiime2_diversity_alpha'
//include { QIIME2_DIVERSITY_BETA as REFMERGE_DIVERSITY_BETA } from '../../modules/local/qiime2_diversity_beta'
//include { QIIME2_DIVERSITY_ADONIS as REFMERGE_DIVERSITY_ADONIS } from '../../modules/local/qiime2_diversity_adonis'
//include { QIIME2_DIVERSITY_BETAORD as REFMERGE_DIVERSITY_BETAORD } from '../../modules/local/qiime2_diversity_betaord'
// include { REFMERGE_PLOT_DIVERSITY_MULTIQC } from '../../modules/local/refmerge_plot_diversity_multiqc'
//include { REFMERGE_BETA_DIVERSITY_PLOT } from '../../modules/local/refmerge_beta_diversity_plot'

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
    REFMERGE_DIVERSITYCORE ( ch_metadata, ch_asv, ch_mintotal )

    //alpha_diversity ( ch_metadata, DIVERSITY_CORE.out.qza, ch_metacolumn_all )
    //ch_metadata
     //   .combine( REFMERGE_DIVERSITY_CORE.out.vector.flatten() )
      //  .combine( ch_metacolumn_all )
      //  .set{ ch_to_diversity_alpha }
    //REFMERGE_DIVERSITY_ALPHA ( ch_to_diversity_alpha )
    //beta_diversity ( ch_metadata, DIVERSITY_CORE.out.qza, ch_metacolumn_pairwise )
    //ch_metadata
      //  .combine( REFMERGE_DIVERSITY_CORE.out.distance.flatten() )
       // .combine( ch_metacolumn_pairwise )
       // .set{ ch_to_diversity_beta }
    //REFMERGE_DIVERSITY_BETA ( ch_to_diversity_beta )
    //adonis ( ch_metadata, DIVERSITY_CORE.out.qza, ch_metacolumn_all )
    //REFMERGE_DIVERSITY_ADONIS ( ch_to_diversity_beta )
    //beta_diversity_ordination ( ch_metadata, DIVERSITY_CORE.out.qza )
    //ch_metadata
        //.combine( REFMERGE_DIVERSITY_CORE.out.pcoa.flatten() )
        //.set{ ch_to_diversity_betaord }
    //REFMERGE_DIVERSITY_BETAORD ( ch_to_diversity_betaord )

    //REFMERGE_BETA_DIVERSITY_PLOT (
        //REFMERGE_DIVERSITY_CORE.out.metadata_diversity.collect(),
        //ch_metacolumn_pairwise,
        //REFMERGE_DIVERSITY_BETA.out.tsv.collect()
    //)

emit:
//alpha_diversity_plot    = REFMERGE_DIVERSITY_ALPHA.out.metadata_tsv.collect().ifEmpty([])
rarefaction_plot        = REFMERGE_ALPHARAREFACTION.out.rarefaction_csv
//beta_diversity          = REFMERGE_BETA_DIVERSITY_PLOT.out.report.collect()
alpha_rarefaction       = REFMERGE_ALPHARAREFACTION.out.alpha_rarefaction
diversity_core_vis      = REFMERGE_DIVERSITYCORE.out.qzv.collect().ifEmpty([])
sample_removed_summary  = REFMERGE_DIVERSITYCORE.out.sample_removed.collect().ifEmpty([])
//betaord_vis             = REFMERGE_DIVERSITY_BETAORD.out.qzv.collect().ifEmpty([])
//alpha_vis               = REFMERGE_DIVERSITY_ALPHA.out.qzv.collect().ifEmpty([])
//beta_vis                = REFMERGE_DIVERSITY_BETA.out.qzv.collect().ifEmpty([])
}
