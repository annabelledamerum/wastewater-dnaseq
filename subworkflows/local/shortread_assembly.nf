//
// Perform metagenome assembly
//

include { SPADES  } from '../../modules/local/spades'
include { MEGAHIT } from '../../modules/local/megahit'
include { QUAST   } from '../../modules/local/quast'

workflow SHORTREAD_ASSEMBLY {
    take:
    reads

    main:
    ch_versions        = Channel.empty()
    ch_multiqc_files   = Channel.empty()
    
    // Conditional execution based on 'assembler_sr' parameter
    if (params.assembler_sr == 'spades') {
        // SPADES metagenome assembly (short, PE reads)    
        SPADES ( reads ).assembly
        ch_assembly = SPADES.out.assembly
        ch_versions = ch_versions.mix( SPADES.out.versions.first() )

        // QUAST metagenome assessment
        QUAST ( ch_assembly )
        ch_versions      = ch_versions.mix( QUAST.out.versions.first() )
        ch_multiqc_files = ch_multiqc_files.mix( QUAST.out.report )
    } else if (params.assembler_sr == 'megahit') {
        // MEGAHIT metagenome assembly
        MEGAHIT ( reads ).assembly
        ch_assembly = MEGAHIT.out.assembly
        ch_versions = ch_versions.mix( MEGAHIT.out.versions.first() )

        // QUAST metagenome assessment
        QUAST ( ch_assembly )
        ch_versions      = ch_versions.mix( QUAST.out.versions.first() )
        ch_multiqc_files = ch_multiqc_files.mix( QUAST.out.report )
    } else {
        error "Unsupported assembler specified: ${params.assembler_sr}. Use 'spades' or 'megahit'."
    }

    emit:
    assembly = ch_assembly
    versions = ch_versions
    mqc      = ch_multiqc_files
}