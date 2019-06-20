#!/bin/bash
INSTALL_DIR=/var/opt/ONAP

#####################################################################
# Start display on 256 if it has not already been started...
# This will stay up and be used for all soak tests
# Tried this once and got an unexpected error so restored the start/kill
# pattern for each test for now.
# Perhaps the error was unrelated to the using the same display for 
# all tests. Preserve this just in case....
function start_display_if
{
	export DISPLAY=:256
    xdpyinfo -display $DISPLAY >/dev/null 2>&1
    while [ $? = 1 ]
    do
		# Start Xvfb
		echo -e "Starting Xvfb on display ${DISPLAY} with res ${RES}"
		Xvfb ${DISPLAY} -ac -screen 0 ${RES} +extension RANDR &
		disown
    done
}

#####################################################################
function start_display
{
	export DISPLAY=:$(( $TEST_NUMBER % 256 ))
    xdpyinfo -display $DISPLAY >/dev/null 2>&1
    while [ $? = 0 ]
    do
	   DISPLAY=$(( $RANDOM % 1000 ))
       xdpyinfo -display $DISPLAY >/dev/null 2>&1
    done
	# Start Xvfb
	echo -e "Starting Xvfb on display ${DISPLAY} with res ${RES}"
	Xvfb ${DISPLAY} -ac -screen 0 ${RES} +extension RANDR &
	XVFBPID=$!
	disown
	echo ${DISPLAY} > /tmp/robotDisplay.$TEST_NUMBER
	# Get and save pid of this spawned process to make sure we kill the correct process later
}

#####################################################################
function kill_display
{
    xdpyinfo -display $DISPLAY >/dev/null 2>&1
    if [ $? = 0 ]; then
       kill -9 $XVFBPID >/dev/null 2>&1
    fi
    rm -rf   /tmp/robotDisplay.$TEST_NUMBER
}

#####################################################################
# main
#####################################################################
export ROBOT_TAG=$1
export TEST_NUMBER=$2

if [ "$TEST_NUMBER" = "" ];then
    TEST_NUMBER=$$
fi

# Use default if none specified as env var
DEFAULT_LOG_LEVEL="INFO" # Available levels: TRACE, DEBUG, INFO (default), WARN, NONE (no logging)
LOG_LEVEL=${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}

# To mitigate the chromedriver hanging issue
export DBUS_SESSION_BUS_ADDRESS=/dev/null

RES="1280x1024x24"
OUTPUT_FOLDER=/share/logs/${SOAKSUBFOLDER}runEteTag_$TEST_NUMBER
mkdir -p $OUTPUT_FOLDER
INSTALL_DIR="/var/opt/ONAP"

ROBOT_LIBS=./robot/library:./robot/library/ONAPLibrary:./robot/library/heatbridge
VARIABLEFILES="-V /share/config/vm_properties.py -V /share/config/integration_robot_properties.py -V /share/config/integration_preload_parameters.py"
VARIABLES="-v GLOBAL_BUILD_NUMBER:$TEST_NUMBER"
LISTENERS=

start_display

# Execute tests
echo -e "Executing robot test ${ROBOT_TAG} at log level ${LOG_LEVEL}"

cd ${INSTALL_DIR}
python -m robot.run -L ${LOG_LEVEL} -d ${OUTPUT_FOLDER} ${VARIABLEFILES} ${VARIABLES} ${LISTENERS} -P ${ROBOT_LIBS} -i ${ROBOT_TAG} $(pwd) > ${OUTPUT_FOLDER}/robot.out 2>&1

####################################################################
# Stop Xvfb we started earlier
kill_display
