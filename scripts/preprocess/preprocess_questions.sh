#!/usr/bin/env bash
source scripts/common.sh

DATA_ROOT=${ROOT}/dataset/
python preprocess/create_dictionary.py --data_root ${DATA_ROOT}
python preprocess/compute_softscore.py --data_root ${DATA_ROOT}/VQA2/
