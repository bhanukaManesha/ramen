#!/usr/bin/env bash
source scripts/common.sh
cd ${PROJECT_ROOT}

#ROOT=/hdd/robik
#NUM_BOXES=36
DATA_SET=CLEVR-Humans

DATA_ROOT=$ROOT/$DATA_SET
PROJ_ROOT=$ROOT/projects/bottom-up-attention-vqa
SRC_CKPT=$PROJ_ROOT/results/CLEVR_only_but_with_Humans_Vocab.log

source activate py2
## We will use CLEVR's dictionary file to update CLEVR-Humans' dictionary
#python -u tools/create_dictionary.py --root $ROOT --dataset $DATA_SET --old_dictionary_file $ROOT/CLEVR/bottom-up-attention/dictionary.pkl
## We will continue using ans2label and label2ans from CLEVR
#python -u tools/compute_softscore.py --dataroot $DATA_ROOT --dataset $DATA_SET --ans2label_file $ROOT/CLEVR/bottom-up-attention/trainval_ans2label.pkl

# CLEVR-Humans has additional tokens which won't be supported by model trained on CLEVR, so just use CLEVR's ntoken (i.e. 87)
source activate vqa
CUDA_VISIBLE_DEVICES=2 python -u main_bottom_up_vqa.py \
--root $ROOT --dataset $DATA_SET \
--output results/CLEVR_Humans_before_ft.log \
--answers_available 1 \
--mode test \
--test_on val \
--checkpoint_path $SRC_CKPT/latest-model.pth \
--pretrained_on CLEVR \
--dictionary_file $ROOT/CLEVR/bottom-up-attention/dictionary_with_Humans_Vocab.pkl

# --w_emb_size 87
#
#CUDA_VISIBLE_DEVICES=0 python -u main_bottom_up_vqa.py --root $ROOT --dataset $DATA_SET \
#--output results/$DATA_SET_test.log \
#--answers_available 0 \
#--mode test \
#--test_on test_dev \
#--checkpoint latest-model.pth

#CUDA_VISIBLE_DEVICES=0 python -u main_bottom_up_vqa.py --root $ROOT --dataset $DATA_SET \
#--output results/$DATA_SET_test.log \
#--answers_available 0 \
#--mode test \
#--test_on test \
#--checkpoint latest-model.pth