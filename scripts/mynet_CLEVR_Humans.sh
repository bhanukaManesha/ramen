#!/usr/bin/env bash

source scripts/common.sh
cd ${PROJECT_ROOT}

DATA_SET=CLEVR_Humans
DATA_ROOT=${PROJECT_ROOT}/dataset/${DATA_SET}

# Convert to VQA2-like format
# python -u preprocess/convert_from_clevr_humans_to_vqa_format.py --data_root ${DATA_ROOT}
# Create dictionary and compute GT answer scores
# python preprocess/create_dictionary.py --data_root ${DATA_ROOT}
# python preprocess/compute_softscore.py --data_root ${DATA_ROOT}

RESULTS_ROOT=${PROJECT_ROOT}/results/${DATA_SET}_results
mkdir -p ${RESULTS_ROOT}
MODEL=Mynet
EXPT_NAME=${MODEL}_${DATA_SET}_multiplicative_fusion

python -u run_network.py \
--data_set ${DATA_SET} \
--data_root ${DATA_ROOT} \
--expt_name ${EXPT_NAME} \
--model ${MODEL} \
--multiplicative_fusion \
--q_emb_dim 2560 \
--spatial_feature_type mesh \
--spatial_feature_length 16 \
--epochs 100 \
--h5_prefix use_split 2>&1 | tee ${RESULTS_ROOT}/${EXPT_NAME}.log

# --resume \
# --resume_expt_dir /home/student/Documents/Bhanuka/HonoursProject/ramen/dataset/CLEVR_CoGenTA_results \
