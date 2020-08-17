#!/usr/bin/env bash

source scripts/common.sh

DATASET=dataset
DATA_ROOT=${PROJECT_ROOT}/${DATASET}
RESULTS_ROOT=${PROJECT_ROOT}/${DATASET}_results
#python preprocess/tsv_to_hdf5.py --data_root ${DATA_ROOT} --split trainval
#python preprocess/tsv_to_hdf5.py --data_root ${DATA_ROOT} --split test2015

ln -s ${DATA_ROOT}/features/trainval.hdf5 ${DATA_ROOT}/features/train.hdf5
ln -s ${DATA_ROOT}/features/trainval.hdf5 ${DATA_ROOT}/features/val.hdf5
ln -s ${DATA_ROOT}/features/trainval_ids_map.json ${DATA_ROOT}/features/train_ids_map.json
ln -s ${DATA_ROOT}/features/trainval_ids_map.json ${DATA_ROOT}/features/val_ids_map.json