//
// Perform metagenome binning
//

include { BOWTIE2_BUILD as BOWTIE2_BUILD_MAGS                             } from '../../modules/nf-core/bowtie2/build'
include { BOWTIE2_ALIGN as BOWTIE2_ALIGN_MAGS                             } from '../../modules/nf-core/bowtie2/align'
include { METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS                            } from '../../modules/local/metabat2/jgisummarizebamcontigdepths'
include { METABAT2_METABAT2                                               } from '../../modules/local/metabat2/metabat2'
include { MAXBIN2                                                         } from '../../modules/local/maxbin2'
include { DASTOOL_FASTATOCONTIG2BIN as DASTOOL_FASTATOCONTIG2BIN_METABAT2 } from '../../modules/local/dastool/fastatocontig2bin'
include { DASTOOL_FASTATOCONTIG2BIN as DASTOOL_FASTATOCONTIG2BIN_MAXBIN2  } from '../../modules/local/dastool/fastatocontig2bin'
include { DASTOOL_DASTOOL                                                 } from '../../modules/local/dastool/dastool'

workflow BINNING {
    take: 
    assemblies
    reads

    main:
    ch_versions        = Channel.empty()
    ch_multiqc_files   = Channel.empty()
    ch_bowtie2_bam     = Channel.empty()
    ch_metabat_depths  = Channel.empty()
   
    // build bowtie2 index for all assemblies
    //ch_BOWTIE2  = BOWTIE2_BUILD ( assemblies ).index
    BOWTIE2_BUILD_MAGS ( assemblies )
    ch_bowtie2_index = BOWTIE2_BUILD_MAGS.out.index
    ch_versions      = ch_versions.mix( BOWTIE2_BUILD_MAGS.out.versions )

    // align reads to metagenome assemblies
    //ch_align         = BOWTIE2_ALIGN ( reads, ch_BOWTIE2, true, true ).bam
    BOWTIE2_ALIGN_MAGS ( reads, ch_bowtie2_index, true, true )
    ch_bowtie2_bam   = ch_bowtie2_bam.mix(BOWTIE2_ALIGN_MAGS.out.bam)
    ch_versions      = ch_versions.mix( BOWTIE2_ALIGN_MAGS.out.versions.first() )
    ch_multiqc_files = ch_multiqc_files.mix( BOWTIE2_ALIGN_MAGS.out.log )

    // binning
    // generate coverage depths for each contig - metabat2 format
    METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS ( ch_bowtie2_bam )
    ch_metabat_depths = ch_metabat_depths.mix(METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS.out.depth)
    ch_versions       = ch_versions.mix( METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS.out.versions.first() )
    
    // create binning input channel
    ch_binning_input = assemblies
        .map { meta, assembly ->
            [meta, assembly] 
        }
        .join( ch_metabat_depths, by: 0 )
        .map { meta, assembly, depth ->
            [meta, assembly, depth] 
        }
    
    // binning  with metabat2
    METABAT2_METABAT2 ( ch_binning_input )
    ch_metabat_bins = METABAT2_METABAT2.out.binned_fastas
    ch_versions     = ch_versions.mix( METABAT2_METABAT2.out.versions.first() )

    // binning with maxbin2
    //MAXBIN2 ( ch_binning_input )
    //ch_maxbin_bins = MAXBIN2.out.binned_fastas
    //ch_versions    = ch_versions.mix( MAXBIN2.out.versions.first() )

    // May create separate bin refinement workflow
    // bin refinement with DAS_Tool
    // prepare contigs-to-bin table input files
    // metabat2
    //ch_dastool_metabat_bin = DASTOOL_FASTATOCONTIG2BIN_METABAT2 ( ch_metabat_bins, "fasta" ).fastatocontig2bin
    // maxbin2
    //ch_dastool_maxbin_bin  = DASTOOL_FASTATOCONTIG2BIN_MAXBIN2 ( ch_maxbin_bins, "fa" ).fastatocontig2bin
    //ch_versions            = ch_versions.mix( DASTOOL_FASTATOCONTIG2BIN_METABAT2.out.versions.first() )
    // run DAS_Tool
    //DASTOOL_DASTOOL ( assemblies, ch_dastool_maxbin_bin, ch_dastool_metabat_bin )
    //ch_versions     = ch_versions.mix( DASTOOL_DASTOOL.out.versions.first() )

    emit:
    //ch_bins_refined = DASTOOL_DASTOOL.out.bins
    metabat_bins = ch_metabat_bins
    //maxbin_bins  = ch_maxbin_bins
    versions     = ch_versions
    mqc          = ch_multiqc_files
}