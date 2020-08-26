#!/usr/bin/env bash
set -e
source scripts/common.sh
cd ${PROJECT_ROOT}

DATA_SET=TDIUC
TEST_DATASET=TDIUC
DATA_ROOT=${PROJECT_ROOT}/dataset/${DATA_SET}

# Commands to extract TDIUC features in the feature extractor (will not work here)
# ./tools/generate_tsv.py --split tdiuc_train --cfg experiments/cfgs/faster_rcnn_end2end_resnet.yml --def models/vg/ResNet-101/faster_rcnn_end2end_final/test.prototxt --out traintdiuc_resnet101_faster_rcnn_genome.tsv --net data/faster_rcnn_models/resnet101_faster_rcnn_final.caffemodel
# ./tools/generate_tsv.py --split tdiuc_val --cfg experiments/cfgs/faster_rcnn_end2end_resnet.yml --def models/vg/ResNet-101/faster_rcnn_end2end_final/test.prototxt --out valtdiuc_resnet101_faster_rcnn_genome.tsv --net data/faster_rcnn_models/resnet101_faster_rcnn_final.caffemodel

# Create dictionary and compute GT answer scores
python preprocess/create_dictionary.py --data_root ${DATA_ROOT}
python preprocess/compute_softscore.py --data_root ${DATA_ROOT}

# Train the model
RESULTS_ROOT=${PROJECT_ROOT}/dataset/${DATA_SET}/${DATA_SET}_results
mkdir -p ${RESULTS_ROOT}
MODEL=Ramen
EXPT_NAME=${MODEL}_${DATA_SET}_${TEST_DATASET}

python -u run_network.py \
--data_set ${DATA_SET} \
--data_root ${DATA_ROOT} \
--expt_name ${EXPT_NAME} \
--model ${MODEL} \
--words_dropout 0.5 \
--question_dropout_after_rnn 0.5 \
--h5_prefix use_split 2>&1 | tee ${RESULTS_ROOT}/${EXPT_NAME}.log