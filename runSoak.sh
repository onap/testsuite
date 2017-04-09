#!/bin/bash
INSTALL_DIR=/var/opt/OpenECOMP_ETE
DURATION=$1

cd ${INSTALL_DIR}
export PYTHONPATH=${INSTALL_DIR}/robot/library
python -m loadtest.TestMain -d ${DURATION} --logfile /share/logs/soak_$$.log