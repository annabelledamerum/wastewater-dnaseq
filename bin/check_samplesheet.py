#!/usr/bin/env python

from distutils import extension
import os
import sys
import errno
import argparse
import re
import pandas as pd

def parse_args(args=None):
    Description = "Reformat nf-core/taxprofiler samplesheet file and check its contents."

    Epilog = "Example usage: python check_samplesheet.py <FILE_IN> <FILE_OUT>"

    parser = argparse.ArgumentParser(description=Description, epilog=Epilog)
    parser.add_argument("FILE_IN", help="Input samplesheet file.")
    parser.add_argument("FILE_OUT", help="Output file.")
    return parser.parse_args(args)


def make_dir(path):
    if len(path) > 0:
        try:
            os.makedirs(path)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                raise exception


def print_error(error, context="Line", context_str=""):
    error_str = "ERROR: Please check samplesheet -> {}".format(error)
    if context != "" and context_str != "":
        error_str = "ERROR: Please check samplesheet -> {}\n{}: '{}'".format(
            error, context.strip(), context_str.strip()
        )
    print(error_str)
    sys.exit(1)


def check_samplesheet(file_in, file_out):
    """
    This function checks that the samplesheet follows the following structure:

    sample,run_accession,instrument_platform,fastq_1,fastq_2,fasta
    2611,ERR5766174,ILLUMINA,,,ERX5474930_ERR5766174_1.fa.gz
    2612,ERR5766176,ILLUMINA,ERX5474932_ERR5766176_1.fastq.gz,ERX5474932_ERR5766176_2.fastq.gz,
    2612,ERR5766174,ILLUMINA,ERX5474936_ERR5766180_1.fastq.gz,,
    2613,ERR5766181,ILLUMINA,ERX5474937_ERR5766181_1.fastq.gz,ERX5474937_ERR5766181_2.fastq.gz,
    """

    FQ_EXTENSIONS = (".fq.gz", ".fastq.gz")
    FA_EXTENSIONS = (
        ".fa.gz",
        ".fasta.gz",
        ".fna.gz",
        ".fas.gz",
    )
    INSTRUMENT_PLATFORMS = [
        "ABI_SOLID",
        "BGISEQ",
        "CAPILLARY",
        "COMPLETE_GENOMICS",
        "DNBSEQ",
        "HELICOS",
        "ILLUMINA",
        "ION_TORRENT",
        "LS454",
        "OXFORD_NANOPORE",
        "PACBIO_SMRT",
    ]

    sample_mapping_dict = {}
    with open(file_in, "r") as fin:
        ## Check header
        MIN_COLS = 5
        HEADER = [
            "sample",
            "run_accession",
            "instrument_platform",
            "fastq_1",
            "fastq_2",
            "fasta",
            "group"
        ]
        header = [x.strip('"') for x in fin.readline().strip().split(",")]

        ## Check for missing mandatory columns
        missing_columns = list(set(HEADER) - set(header))
        if len(missing_columns) > 0:
            print(
                "ERROR: Missing required column header -> {}. Note some columns can otherwise be empty. See pipeline documentation (https://nf-co.re/taxprofiler/usage).".format(
                    ",".join(missing_columns)
                )
            )
            sys.exit(1)

        ## Find locations of mandatory columns
        header_locs = {}
        for i in HEADER:
            header_locs[i] = header.index(i)

        ## Check sample entries
        groups = []
        labels = []
        for line in fin:
            ## Pull out only relevant columns for downstream checking
            line_parsed = [x.strip().strip('"') for x in line.strip().split(",")]

            # Check valid number of columns per row
            if len(line_parsed) < len(HEADER):
                print_error(
                    "Invalid number of columns (minimum = {})!".format(len(HEADER)),
                    "Line",
                    line,
                )
            num_cols = len([x for x in line_parsed if x])
            if num_cols < MIN_COLS:
                print_error(
                    "Invalid number of populated columns (minimum = {})!".format(MIN_COLS),
                    "Line",
                    line,
                )

            lspl = [line_parsed[i] for i in header_locs.values()]

            ## Check sample name entries

            (
                sample,
                run_accession,
                instrument_platform,
                fastq_1,
                fastq_2,
                fasta,
                group
            ) = lspl[: len(HEADER)]
            sample = sample.replace(" ", "_")
            legal_pattern = r"^[a-zA-Z][a-zA-Z0-9_]*$"
            illegal_patterns = ["_tophat", "ReadsPerGene", "_star_aligned", "_fastqc", "_counts", "Aligned", "_slamdunk", "_bismark", "_SummaryStatistics", \
                        "_duprate", "_vep", "ccs", "_NanoStats", "_R1", "_R2", "_trimmed", "_val", "_mqc", "short_summary_", "_summary", "_matrix", \
                        r"_$", r"^R1", r"^R2", "_isomiRs_results", "_deseq2_results", "_dinucleotide_frequency", "_rseqc"]
            if not sample:
                print_error("Sample entry has not been specified!", "Line", line)
            if sample:
                assert re.match(legal_pattern, sample), "Sample label {} contains illegal characters or does not start with letters!".format(sample)
                for phrase in illegal_patterns:
                    assert re.search(phrase, sample) == None, "Sample label {} contains file phrase(s) that will be automatically filtered out by MultiQC in the final report. Please choose a different label.".format(sample)
                assert sample not in labels, "Duplicate sample label {}".format(sample)
                labels.append(sample)

            if group:
                assert re.match(legal_pattern, group), "Group label {} contains illegal characters or does not start with letters!".format(group)
                for phrase in illegal_patterns:
                    assert re.search(phrase, group) == None, "Group label {} contains file phrase(s) that may be automatically filtered out by MultiQC in the final report. Please choose a different label.".format(group)
                groups.append(group)
                assert len(groups)==0 or len(groups) == len(labels), "Group label(s) missing in some but not all samples!"

            ## Check FastQ file extension
            for fastq in [fastq_1, fastq_2]:
                if fastq:
                    if fastq.find(" ") != -1:
                        print_error("FastQ file contains spaces!", "Line", line)
                    if not fastq.endswith(FQ_EXTENSIONS):
                        print_error(
                            f"FastQ file does not have extension {' or '.join(list(FQ_EXTENSIONS))} !",
                            "Line",
                            line,
                        )
            if fasta:
                if fasta.find(" ") != -1:
                    print_error("FastA file contains spaces!", "Line", line)
                if not fasta.endswith(FA_EXTENSIONS):
                    print_error(
                        f"FastA file does not have extension {' or '.join(list(FA_EXTENSIONS))}!",
                        "Line",
                        line,
                    )
            sample_info = []

            # Check run_accession
            if not run_accession:
                print_error("Run accession has not been specified!", "Line", line)
            else:
                sample_info.append(run_accession)

            # Check instrument_platform
            if not instrument_platform:
                print_error("Instrument platform has not been specified!", "Line", line)
            else:
                if instrument_platform not in INSTRUMENT_PLATFORMS:
                    print_error(
                        f"Instrument platform {instrument_platform} is not supported! "
                        f"List of supported platforms {', '.join(INSTRUMENT_PLATFORMS)}",
                        "Line",
                        line,
                    )
                sample_info.append(instrument_platform)

            ## Auto-detect paired-end/single-end
            if sample and fastq_1 and fastq_2:  ## Paired-end short reads
                sample_info.extend(["0", fastq_1, fastq_2, fasta])
            elif sample and fastq_1 and not fastq_2:  ## Single-end short/long fastq reads
                sample_info.extend(["1", fastq_1, fastq_2, fasta])
            elif sample and fasta and not fastq_1 and not fastq_2:  ## Single-end long reads
                sample_info.extend(["1", fastq_1, fastq_2, fasta])
            elif fasta and (fastq_1 or fastq_2):
                print_error(
                    "FastQ and FastA files cannot be specified together in the same library!",
                    "Line",
                    line,
                )
            else:
                print_error("Invalid combination of columns provided!", "Line", line)
            
            sample_info.append(group)

            ## Create sample mapping dictionary = { sample: [ run_accession, instrument_platform, single_end, fastq_1, fastq_2 , fasta ] }
            if sample not in sample_mapping_dict:
                sample_mapping_dict[sample] = [sample_info]
            else:
                if sample_info in sample_mapping_dict[sample]:
                    print_error("Samplesheet contains duplicate rows!", "Line", line)
                else:
                    sample_mapping_dict[sample].append(sample_info)

    ## Write validated samplesheet with appropriate columns
    HEADER_OUT = [
        "sample",
        "run_accession",
        "instrument_platform",
        "single_end",
        "fastq_1",
        "fastq_2",
        "fasta",
        "group"
    ]
    if len(sample_mapping_dict) > 0:
        out_dir = os.path.dirname(file_out)
        make_dir(out_dir)
        with open(file_out, "w") as fout:
            fout.write(",".join(HEADER_OUT) + "\n")
            for sample in sorted(sample_mapping_dict.keys()):
                for idx, val in enumerate(sample_mapping_dict[sample]):
                    fout.write(f"{sample},{','.join(val)}\n")
    else:
        print_error("No entries to process!", "Samplesheet: {}".format(file_in))

    metadata = pd.read_csv(file_out)
    metadata = metadata[["sample", "group"]]
    metadata.columns = ["sampleid", "group"]
    metadata.to_csv("group_metadata.csv", sep="\t", index=False)

def main(args=None):
    args = parse_args(args)
    check_samplesheet(args.FILE_IN, args.FILE_OUT)


if __name__ == "__main__":
    sys.exit(main())
