#!/usr/bin/env bash
set -e
source scripts/common.sh
cd ${PROJECT_ROOT}

DATA_SET=VQACP
DATA_ROOT=/hdd/robik/${DATA_SET}

# Create dictionary and compute GT answer scores
#python preprocess/create_dictionary.py --data_root ${DATA_ROOT}
#python preprocess/compute_softscore.py --data_root ${DATA_ROOT} --top_k 3000

# Train the model
RESULTS_ROOT=/hdd/robik/${DATA_SET}_results
mkdir -p ${RESULTS_ROOT}
MODEL=UpDn
EXPT_NAME=rubi_${MODEL}_${DATA_SET}_256

CUDA_VISIBLE_DEVICES=1 python -u run_network.py \
--data_set ${DATA_SET} \
--data_root ${DATA_ROOT} \
--expt_name ${EXPT_NAME} \
--model ${MODEL} \
--apply_rubi \
--q_emb_dim 2048 \
--lr 0.0003 \
--optimizer Adam \
--batch_size 256 \
--h5_prefix use_split > ${RESULTS_ROOT}/${EXPT_NAME}.log

EXPT_NAME=${MODEL}_${DATA_SET}_256
CUDA_VISIBLE_DEVICES=1 python -u run_network.py \
--data_set ${DATA_SET} \
--data_root ${DATA_ROOT} \
--expt_name ${EXPT_NAME} \
--model ${MODEL} \
--q_emb_dim 2048 \
--lr 0.0003 \
--optimizer Adam \
--batch_size 256 \
--h5_prefix use_split > ${RESULTS_ROOT}/${EXPT_NAME}.log