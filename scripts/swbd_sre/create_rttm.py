#!/usr/bin/env python3

import argparse

# This script creates the RTTM file based on the segments file.
# The RTTM file has the format
# SPEAKER iaaa 0 6.14 2.99 <NA> <NA> B <NA> <NA>

# VERSION MODIFIED FOR CHIME6

parser = argparse.ArgumentParser("Create RTTM file from segments file for SWBD SRE dataset")
parser.add_argument('segments_file', type=str, help='segments file')
parser.add_argument('output_dir', type=str, help='output directory')

def create_rttm(segments_file, output_dir):
    utt_list = []
    rttm_file = open("{}/rttm".format(output_dir), 'w')
    with open(segments_file, 'r') as fh:
        content = fh.readlines()
    for line in content:
        line = line.strip('\n')
        line_split = line.split()
        uttname = line_split[0]
        wav_name = line_split[1]
        starttime = float(line_split[2])
        endtime = float(line_split[3])
        duration = endtime - starttime

        # uttname format:
        # P56_S24_U01_NOLOCATION.CH4-0910368-0910452
        person, session, array, rest = uttname.split('_')
        room, rest = rest.split('.')
        channel, _, __ = rest.split('-')

        # assert len(uttname_split) == 3
        # new_uttname = uttname.split('-')[0]
        new_uttname = wav_name

        if len(utt_list) == 0 or utt_list[-1] != new_uttname:
            utt_list.append(new_uttname)

        spkname = f'{person}'
        rttm_file.write(f"SPEAKER {new_uttname} 1 {starttime:.2f} {duration:.2f} <NA> <NA> {spkname} <NA> <NA>\n")
    rttm_file.close()
    return utt_list

def main(args):
    # create RTTM file
    utt_list = create_rttm(args.segments_file, args.output_dir)
    print("Finish preparing RTTM file for {} utterances".format(len(utt_list)))
    return 0

if __name__ == "__main__":
    args = parser.parse_args()
    main(args)
