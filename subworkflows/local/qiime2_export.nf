/*
 * Export filtered tables from QIIME2
 */
include { FIND_MAX_AVAILABLE_TAX } from '../../modules/local/find_max_available_tax'
include { QIIME2_EXPORT_ABSOLUTE } from '../../modules/local/qiime2_export_absolute'
include { QIIME2_EXPORT_RELTAX   } from '../../modules/local/qiime2_export_reltax'

workflow QIIME2_EXPORT {
    take:
    ch_asv
    taxonomy_qza
    taxonomy_tsv
    tax_agglom_min
    tax_agglom_max

    main:
    //Find max available taxonomy level, check against specified tax levels
    FIND_MAX_AVAILABLE_TAX ( taxonomy_tsv )
    FIND_MAX_AVAILABLE_TAX.out.max_tax.subscribe { it ->
        if (it.toInteger() < tax_agglom_max) { log.warn "Max available taxonomy is $it, but requested tax_agglom_max=$tax_agglom_max, switching to $it" }
        if (it.toInteger() < tax_agglom_min) { log.warn "Max available taxonomy is $it, but requested tax_agglom_min=$tax_agglom_min, switching to $it" }
    }

    tax_min = FIND_MAX_AVAILABLE_TAX.out.max_tax.toInteger().map{ [it, tax_agglom_min].min() }
    tax_max = FIND_MAX_AVAILABLE_TAX.out.max_tax.toInteger().map{ [it, tax_agglom_max].min() }

    //export_filtered_dada_output (optional)
    QIIME2_EXPORT_ABSOLUTE ( ch_asv, taxonomy_qza, taxonomy_tsv, tax_min, tax_max )

    QIIME2_EXPORT_ABSOLUTE.out.collapse_lvl7_qza
        .ifEmpty("There were no samples or taxa left after filtering! Try lower filtering criteria or examine your data quality.")
        .filter( String )
        .set{ ch_warning_message }

    emit:
    abs_tsv             = QIIME2_EXPORT_ABSOLUTE.out.tsv
    abs_taxa_levels     = QIIME2_EXPORT_ABSOLUTE.out.abundtable
    collapse_qza        = QIIME2_EXPORT_ABSOLUTE.out.collapse_qza
    collapse_tsv        = QIIME2_EXPORT_ABSOLUTE.out.abundtable
    lvl7_tsv            = QIIME2_EXPORT_ABSOLUTE.out.collapse_lvl7_tsv
    lvl7_qza            = QIIME2_EXPORT_ABSOLUTE.out.collapse_lvl7_qza
}
