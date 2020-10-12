#!/usr/bin/env bash
set -e
source scripts/common.sh
cd ${PROJECT_ROOT}


DATA_SET=TDIUC
DATA_ROOT=${PROJECT_ROOT}/dataset/${DATA_SET}

# Create dictionary and compute GT answer scores
#  python preprocess/create_dictionary.py --data_root ${DATA_ROOT}
#  python preprocess/compute_softscore.py --data_root ${DATA_ROOT} --min_occurrence 0 --tdiuc

# Train the model
RESULTS_ROOT=${PROJECT_ROOT}/results/${DATA_SET}_results
mkdir -p ${RESULTS_ROOT}
MODEL=Mynet
EXPT_NAME=${MODEL}_${DATA_SET}_baseline

python -u run_network.py \
--data_set ${DATA_SET} \
--data_root ${DATA_ROOT} \
--expt_name ${EXPT_NAME} \
--model ${MODEL} \
--train_split train \
--test_split val \
--epochs 50 \
--words_dropout 0.5 \
--question_dropout_after_rnn 0.5 \
--h5_prefix use_split  2>&1 | tee ${RESULTS_ROOT}/${EXPT_NAME}.log