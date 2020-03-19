#!/bin/bash

# Training the RPNSD model on Mixer6 + SRE + SWBD

. ./cmd.sh
. ./path.sh

#train_dir=data/swbd_sre_final/train_train
#dev_dir=data/swbd_sre_final/train_dev
train_dir=data/chime6_final/train_train
dev_dir=data/chime6_final/train_dev
cfg=res101
cfg_file=cfgs/${cfg}.yml

# data process parameters
padded_len=20

# training parameters
#epochs=1
epochs=100
batch_size=8
num_workers=4
optimizer=sgd
lr=0.01
min_lr=0.0001
scheduler=multi
patience=10
seed=7
alpha=1.0

rate=16000
frame_size=1024
frame_shift=160

# network parameters
arch=res101
#nclass=5963  # TODO: should reflect number of speakers
nclass=33  # 32 speakers in chime

# validate parameters
eval_interval=10
#num_dev=12000
num_dev=3356

exp_dir=experiment/cfg${cfg}epoch${epochs}bs${batch_size}op${optimizer}lr${lr}min_lr${min_lr}scheduler${scheduler}pat${patience}seed${seed}alpha${alpha}arch${arch}dev${num_dev}

mkdir -p $exp_dir/{model,log} || exit 1;

${cuda_cmd} $exp_dir/log/run_log \
	python3 scripts/train.py $exp_dir $train_dir \
	$dev_dir --cfg_file $cfg_file --padded_len $padded_len \
	--epochs $epochs --batch_size $batch_size --num_workers $num_workers --optimizer $optimizer \
	--lr $lr --min_lr $min_lr --scheduler $scheduler --alpha $alpha \
	--patience $patience --seed $seed --arch $arch \
	--nclass $nclass --eval_interval $eval_interval --num_dev $num_dev \
	--use_tfb --rate $rate --frame_size $frame_size --frame_shift $frame_shift
