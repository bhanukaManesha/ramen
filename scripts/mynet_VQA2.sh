#!/usr/bin/env bash

source scripts/common.sh
cd ${PROJECT_ROOT}

DATA_SET=VQA2
DATA_ROOT=${PROJECT_ROOT}/dataset/${DATA_SET}

# Create dictionary and compute GT answer scores
# python preprocess/create_dictionary.py --data_root ${DATA_ROOT}
# python preprocess/compute_softscore.py --data_root ${DATA_ROOT} --min_occurrence 9

RESULTS_ROOT=${PROJECT_ROOT}/results/${DATA_SET}_results
mkdir -p ${RESULTS_ROOT}
MODEL=Mynet
EXPT_NAME=${MODEL}_${DATA_SET}_multiplicative_fusion

python -u run_network.py \
--data_set ${DATA_SET} \
--data_root ${DATA_ROOT} \
--expt_name ${EXPT_NAME} \
--words_dropout 0.5 \
--epochs 25 \
--multiplicative_fusion \
--q_emb_dim 2560 \
--ta_ninp 2560 \
--model ${MODEL} \
--question_dropout_after_rnn 0.5 \
--train_split trainval \
--test_split test \
--spatial_feature_type mesh \
--spatial_feature_length 16 \
--h5_prefix use_split 2>&1 | tee ${RESULTS_ROOT}/${EXPT_NAME}.log

#--resume \
#--resume_expt_dir /home/student/Documents/Bhanuka/HonoursProject/ramen/dataset/VQA2_results \
# --resume \
# --resume_expt_dir /home/student/Documents/Bhanuka/HonoursProject/ramen/dataset/VQACP2_results \
#--resume \
#--resume_expt_dir /home/student/Documents/Bhanuka/HonoursProject/ramen/dataset/CLEVR_results \
#--words_dropout 0.5 \
#--question_dropout_after_rnn 0.5 \