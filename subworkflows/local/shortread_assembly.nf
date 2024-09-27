//
// Perform metagenome assembly
//

include { SPADES } from '../../modules/local/spades'
include { QUAST  } from '../../modules/local/quast'

workflow SHORTREAD_ASSEMBLY {
    take:
    reads

    main:
    ch_versions        = Channel.empty()
    ch_multiqc_files   = Channel.empty()
    
    // SPADES metagenome assembly (short, PE reads)    
    ch_assembly = SPADES ( reads ).assembly
    ch_versions      = ch_versions.mix( SPADES.out.versions.first() )
    
    // QUAST metagenome assessment
    QUAST ( ch_assembly )
    ch_versions      = ch_versions.mix( QUAST.out.versions.first() )
    ch_multiqc_files = ch_multiqc_files.mix( QUAST.out.report )

    emit:
    assembly = SPADES.out.assembly
    versions = ch_versions
    mqc      = ch_multiqc_files
}