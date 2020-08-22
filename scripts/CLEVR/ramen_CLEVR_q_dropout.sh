#!/usr/bin/env bash

source scripts/common.sh
cd ${PROJECT_ROOT}

DATA_SET=CLEVR
DATA_ROOT=/hdd/robik/${DATA_SET}

# Convert to VQA2-like format
#python -u preprocess/convert_from_clevr_to_vqa_format.py --data_root ${DATA_ROOT}
# Create dictionary and compute GT answer scores
#python preprocess/create_dictionary.py --data_root ${DATA_ROOT}
#python preprocess/compute_softscore.py --data_root ${DATA_ROOT}

RESULTS_ROOT=/hdd/robik/${DATA_SET}_results
mkdir -p ${RESULTS_ROOT}
MODEL=Ramen
EXPT_NAME=${MODEL}_${DATA_SET}_q_dropout_0.1

python -u run_network.py \
--data_set ${DATA_SET} \
--data_root ${DATA_ROOT} \
--expt_name ${EXPT_NAME} \
--model ${MODEL} \
--spatial_feature_type mesh \
--spatial_feature_length 16 \
--question_dropout_after_rnn 0.1 \
--h5_prefix use_split > ${RESULTS_ROOT}/${EXPT_NAME}.log

#--words_dropout 0.5 \
#--question_dropout_after_rnn 0.5 \