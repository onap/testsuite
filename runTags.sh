#!/bin/bash

# Set the defaults
DEFAULT_LOG_LEVEL="TRACE" # Available levels: TRACE, DEBUG, INFO (default), WARN, NONE (no logging)
DEFAULT_RES="1280x1024x24"
DEFAULT_DISPLAY=":99"
DEFAULT_ROBOT_TEST="-i health"
INSTALL_NAME="ONAP"
DEFAULT_OUTPUT_FOLDER=./

# To mitigate the chromedriver hanging issue
export DBUS_SESSION_BUS_ADDRESS=/dev/null

# Use default if none specified as env var
LOG_LEVEL=${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}
RES=${RES:-$DEFAULT_RES}
DISPLAY=${DISPLAY:-$DEFAULT_DISPLAY}

# OUTPUT_FOLDER env variable will be overridden by -d command line argument.
OUTPUT_FOLDER=${OUTPUT_FOLDER:-$DEFAULT_OUTPUT_FOLDER}

VARIABLEFILES=
LISTENERS=
VARIABLES="--removekeywords name:keystone_interface.*"

## Single argument, it is an include tag
if [ $# -eq 1 ]; then
    ROBOT_TAGS="-i $1"
fi

##
## if more than 1 tag is supplied, the must be provided with -i or -e
##
while [ $# -gt 1 ]
do
	key="$1"

	case $key in
    	-i|--include)
    	ROBOT_TAGS="${ROBOT_TAGS} -i $2"
    	shift
    	;;
    	-e|--exclude)
    	ROBOT_TAGS="${ROBOT_TAGS} -e $2"
    	shift
    	;;
    	-d|--outputdir)
    	OUTPUT_FOLDER=$2
    	shift
    	;;
  		--display)
    	DISPLAY=:$2
    	shift
    	;;
  		--listener)
    	LISTENERS="${LISTENER} --listener $2 "
    	shift
    	;;
   		-V)
    	VARIABLEFILES="${VARIABLEFILES} -V $2 "
    	shift
    	;;
   		-v)
    	VARIABLES="${VARIABLES} -v $2 "
    	shift
    	;;
	esac
	shift
done

if [ "${ROBOT_TAGS}" = "" ];then
    ROBOT_TAGS=$DEFAULT_ROBOT_TEST
fi

# Start Xvfb
echo -e "Starting Xvfb on display ${DISPLAY} with res ${RES}"
Xvfb ${DISPLAY} -ac -screen 0 ${RES} +extension RANDR &
XVFBPID=$!
# Get pid of this spawned process to make sure we kill the correct process later

export DISPLAY=${DISPLAY}

# Execute tests
echo -e "Executing robot tests at log level ${LOG_LEVEL}"

ROBOT_LIBS=./robot/library:./robot/library/ONAPLibrary:./robot/library/vcpeutils:./robot/library/heatbridge

cd /var/opt/${INSTALL_NAME}
python -m robot.run -L ${LOG_LEVEL} -d ${OUTPUT_FOLDER} ${VARIABLEFILES} ${VARIABLES} ${LISTENERS} -P ${ROBOT_LIBS} ${ROBOT_TAGS} /var/opt/${INSTALL_NAME}/robot/testsuites/
RET_CODE=$?

# Stop Xvfb we started earlier
# select it from list of possible Xvfb pids running because
# a) there may be multiple Xvfbs running and
# b) the XVFBPID may not be the correct if the start did not actually work (unlikely and that may be)
PIDS=$(pgrep Xvfb)
for P in $PIDS
do
	if [ $P == $XVFBPID ];then
		kill -9 $P
	fi
done

exit $RET_CODE
