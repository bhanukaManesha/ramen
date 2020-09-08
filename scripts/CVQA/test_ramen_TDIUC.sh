#!/usr/bin/env bash
set -e
source scripts/common.sh
cd ${PROJECT_ROOT}

DATA_SET=CVQA
TEST_DATASET=TDIUC
DATA_ROOT=${PROJECT_ROOT}/dataset/${DATA_SET}
TEST_DATA_ROOT=${PROJECT_ROOT}/dataset/${TEST_DATASET}

# Train the model
RESULTS_ROOT=${PROJECT_ROOT}/dataset/${DATA_SET}/${DATA_SET}_results
mkdir -p ${RESULTS_ROOT}
MODEL=Ramen
EXPT_NAME=${MODEL}_${DATA_SET}_${TEST_DATASET}
ORIGINAL_EXPT_NAME=${MODEL}_${DATA_SET}_${DATA_SET}

python -u run_network.py \
--data_set ${DATA_SET} \
--data_root ${DATA_ROOT} \
--test_data_root ${TEST_DATA_ROOT} \
--test_data_set ${TEST_DATASET} \
--expt_name ${EXPT_NAME} \
--model ${MODEL} \
--test \
--test_split val \
--words_dropout 0.5 \
--question_dropout_after_rnn 0.5 \
--dictionary_file /mnt/efs/ramen/dataset/${TEST_DATASET}/features/dictionary.pkl \
--resume_expt_dir ${RESULTS_ROOT} \
--resume_expt_name ${ORIGINAL_EXPT_NAME} \
--h5_prefix use_split 2>&1 | tee ${RESULTS_ROOT}/${EXPT_NAME}.log


#--glove_file /mnt/efs/ramen/dataset/${TEST_DATASET}/features/glove6b_init_300d.npy \