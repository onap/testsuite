#!/bin/bash
##################################################################################################
# This shell is designed to support retrieval of application debugging data in the case of
# an ETE test failure. This script, along with the gather_application_data.sh will be installed
# in /opt on each of the ONAP VMs. The gather_application_data function is designed by each
# application to gather the relevant debugging data into the current working directory
# to be zipped up and transferred to the Robot VM and ultimately, posted in the failed Jenkins
# job.
##################################################################################################

JOB_NUMBER=$2
APPLICATION=$1
if [ "$JOB_NUMBER" == '' ];then
   JOB_NUMBER=0
fi
if [ "$APPLICATION" == '' ];then
   APPLICATION='job'
fi

if [ -e /opt/gather_application_data.sh ]; then
    source /opt/gather_application_data.sh
else
    >&2 echo "${APPLICATION} No gather_application_data function"
	exit
fi


FOLDER=/tmp/gather_data/${APPLICATION}_${JOB_NUMBER}
mkdir -p $FOLDER

cd ${FOLDER}

gather_application_data

cd ../
tar --remove-files -cvzf ${APPLICATION}_${JOB_NUMBER}.tar.gz ${APPLICATION}_${JOB_NUMBER}
