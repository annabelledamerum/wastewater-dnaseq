//
// Run RGI on shortreads
//

include { RGI_BWT           } from '../../modules/local/rgi/bwt/main.nf'
include { RGI_MAIN          } from '../../modules/local/rgi/main/main.nf'
include { RGI_KMER_QUERY    } from '../../modules/local/rgi/kmer_query/main.nf'

workflow SHORTREAD_RGI {
    take: 
    reads


    main:
    ch_versions             = Channel.empty()
    ch_bwa_bam_output       = Channel.empty()
    ch_multiqc_files        = Channel.empty()
    ch_output_file_paths    = Channel.empty()

    // Prepare RGI database files
    


}