#!/bin/bash
INSTALL_DIR=/var/opt/OpenECOMP_ETE
#
# Execute tags built to support the hands on demo,
#
function usage
{
	echo "Usage: runSoak.sh [-p <filename> -d <seconds> -c <seconds>]"
	echo " "
	echo "       -p, --profile"
	echo "               - name of JSON file containing test profile"
	echo " "
	echo "       -d, --duration"
	echo "               - Duration of soak test (overrides value --profile)"
	echo " "
	echo "       -c, --cyclelength"
	echo "               - Time between starting iterations of profile"
	echo "                 If longer than total run time of a single iteration,"
	echo "                 additional wait is added before starting the next iteration."
	echo "                 Value has no effect if it is shorter than the total run time"
	echo "                 of a single iteration over the profile."
	echo "                 (overrides value in --profile)"
}


cd ${INSTALL_DIR}
export PYTHONPATH=${INSTALL_DIR}/robot/library
python -m loadtest.TestMain $@ --logfile /share/logs/soak_$$.log