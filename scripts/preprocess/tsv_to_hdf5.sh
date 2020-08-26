#!/usr/bin/env bash

source scripts/common.sh

DATASET=dataset
DATA_ROOT=${PROJECT_ROOT}/${DATASET}
RESULTS_ROOT=${PROJECT_ROOT}/${DATASET}_results
#python preprocess/tsv_to_hdf5.py --data_root ${DATA_ROOT} --split trainval
# python preprocess/tsv_to_hdf5.py --data_root ${DATA_ROOT} --split test2015

# For TDIUC
# python preprocess/tsv_to_hdf5.py --data_root ${DATA_ROOT} --split trainval --tdiuc
# python preprocess/tsv_to_hdf5.py --data_root ${DATA_ROOT} --split test2015 --tdiuc

# ln -s ${DATA_ROOT}/features/trainval.hdf5 ${DATA_ROOT}/features/train.hdf5
# ln -s ${DATA_ROOT}/features/trainval.hdf5 ${DATA_ROOT}/features/val.hdf5
# ln -s ${DATA_ROOT}/features/trainval_ids_map.json ${DATA_ROOT}/features/train_ids_map.json
# ln -s ${DATA_ROOT}/features/trainval_ids_map.json ${DATA_ROOT}/features/val_ids_map.json

# For TDIUC
ln -s ${DATA_ROOT}/features/traintdiuc.hdf5 ${DATA_ROOT}/TDIUC/features/train.hdf5
ln -s ${DATA_ROOT}/features/valtdiuc.hdf5 ${DATA_ROOT}/TDIUC/features/val.hdf5
ln -s ${DATA_ROOT}/features/traintdiuc_ids_map.json ${DATA_ROOT}/TDIUC/features/train_ids_map.json
ln -s ${DATA_ROOT}/features/valtdiuc_ids_map.json ${DATA_ROOT}/TDIUC/features/val_ids_map.json