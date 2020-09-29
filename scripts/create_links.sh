#!/usr/bin/env bash
source scripts/common.sh


# CLEVR_CoGenTA
cd ${PROJECT_ROOT}/dataset/CLEVR_CoGenTA/features

ln -s ../../CLEVR/features/train.hdf5 train.hdf5
ln -s ../../CLEVR/features/train_ids_map.json train_ids_map.json
ln -s ../../CLEVR/features/train_scenes_with_bb.json train_scenes_with_bb.json

ln -s ../../CLEVR/features/val.hdf5 val.hdf5
ln -s ../../CLEVR/features/val_ids_map.json val_ids_map.json
ln -s ../../CLEVR/features/val_scenes_with_bb.json val_scenes_with_bb.json

ln -s ../../CLEVR/features/test.hdf5 test.hdf5
ln -s ../../CLEVR/features/test_ids_map.json test_ids_map.json

cd ${PROJECT_ROOT}/dataset/CLEVR_CoGenTA/glove
ln -s ../../glove/glove.6B.300d.txt glove.6B.300d.txt
