#! /bin/bash

BASEDIR='/home/dianarocio/Downloads/session4'
export PYTHONPATH=$BASEDIR/util

$BASEDIR/corenlp-server.sh -quiet true -port 9000 -timeout 15000  &
sleep 1

# extract features
echo "Extracting features"
python3 extract-features.py $BASEDIR/data/devel/ > devel.cod &
python3 extract-features.py $BASEDIR/data/train/ | tee train.cod | cut -f4- > train.cod

kill `cat /tmp/corenlp-server.running`

# train model
echo "Training model"
./megam-64.opt -quiet -nc -nobias -repeat 4 multiclass train.cod >model.mem
# run model
echo "Running model..."
python3 predict-mem.py model.mem < devel.cod > devel.out
# evaluate results
echo "Evaluating results..."
python3 $BASEDIR/util/evaluator.py DDI $BASEDIR/data/devel/ devel.out > devel.stats

