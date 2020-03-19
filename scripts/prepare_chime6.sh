#!/bin/bash

train_cmd=
nj=32

. ./path.sh
. ./cmd.sh

set -eou pipefail

chime_root="/export/c11/pzelasko/kaldi_chime6_jhu/egs/chime6/s5_track2_small"

# TODO:
# ln -s <...> data/chime_src_{train,dev,eval}

#for dset in train dev test; do
for dset in train; do
  chime_source="data/chime_src_$dset"
  data_dir="data/chime_$dset"

  cp -Lr "$chime_source" "$data_dir"

  python3 scripts/swbd_sre/create_rttm.py $data_dir/segments $data_dir
  sort -k2,2 -k4,4n $data_dir/rttm > $data_dir/rttm_tmp
  mv $data_dir/rttm_tmp $data_dir/rttm

  utils/data/get_utt2dur.sh --nj $nj --cmd "$train_cmd" $data_dir
  python3 scripts/create_spk2idx.py $data_dir
  utils/fix_data_dir.sh $data_dir

  # Note: skipped data cleaning

  uttdur=10.0
  scripts/split_utt.sh \
    --cmd "$train_cmd" \
    --nj $nj \
    --uttlen $uttdur \
    $data_dir \
    ${data_dir}_10s

  awk -F' ' -v dur="$uttdur" '{print $1, dur}' \
    ${data_dir}_10s/wav.scp \
    > ${data_dir}_10s/reco2dur

  scripts/create_record.sh --cmd "$train_cmd" --nj $nj data/${data_dir}_10s
done

# Note: skipped data augmentation

data_dir=data/chime_train
#python3 scripts/swbd_sre/split_train_dev_test.py ${data_dir}_10s data/chime6_final
#python3 scripts/swbd_sre/split_train_dev.py data/chime6_final/train data/chime6_final
mkdir -p data/chime6_final/{train_train,train_dev}
for f in wav.scp label.scp utt2spk spk2utt reco2dur; do
  head -n 55000 data/chime_train_10s/$f > data/chime6_final/train_train/$f
  tail -n 3356 data/chime_train_10s/$f > data/chime6_final/train_dev/$f
done
ln -s "$(pwd)/${data_dir}_10s/data" data/chime6_final/train_train/.
ln -s "$(pwd)/${data_dir}_10s/data" data/chime6_final/train_dev/.

# TODO: CHIME dev and eval data