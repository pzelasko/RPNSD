#!/bin/bash

. ./path.sh
. ./cmd.sh

set -eou pipefail

chime_root="/export/c11/pzelasko/kaldi_chime6_jhu/egs/chime6/s5_track2_small"
voxceleb_source="$chime_root/data/voxceleb_combined_cmn"
sad_name=0012_sad_v1
sad_model="$sad_name/exp/segmentation_1a/tdnn_stats_sad_1a"

if [ ! -f $sad_model/final.raw ]; then
  wget http://kaldi-asr.org/models/12/$sad_name.tar.gz
  tar xf $sad_name.tar.gz
fi

voxceleb_dir=data/voxceleb_combined_cmn
cp -r "$voxceleb_source" "$voxceleb_dir"

steps/segmentation/detect_speech_activity.sh \
  --nj 40 \
  --cmd "$train_cmd" \
  --mfcc-config conf/mfcc_hires.conf \
  "$voxceleb_dir" \
  "$sad_model" \
  mfcc \
  vad_work_dir \
  "$voxceleb_dir"

