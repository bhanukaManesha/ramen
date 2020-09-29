#!/usr/bin/env bash

source scripts/common.sh
cd ${PROJECT_ROOT}

DATA_SET=CLEVR
DATA_ROOT=${PROJECT_ROOT}/dataset/${DATA_SET}


RESULTS_ROOT=${PROJECT_ROOT}/results/${DATA_SET}_results
mkdir -p ${RESULTS_ROOT}
MODEL=Ramen
RESUME_EXPT_NAME=${MODEL}_${DATA_SET}
EXPT_NAME=${RESUME_EXPT_NAME}_test

python -u run_network.py \
--data_set ${DATA_SET} \
--data_root ${DATA_ROOT} \
--expt_name ${EXPT_NAME} \
--model ${MODEL} \
--spatial_feature_type mesh \
--spatial_feature_length 16 \
--test \
--resume_expt_dir ${PROJECT_ROOT}/checkpoints/CLEVR_results \
--resume_expt_name ${RESUME_EXPT_NAME} > ${RESULTS_ROOT}/${EXPT_NAME}.log