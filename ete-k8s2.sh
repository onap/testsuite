# Copyright © 2018 Amdocs, Bell Canada
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/bash

#################################################################
#################################################################
#################################################################
#
#  Example script that uses second openstack tenant for VNFs
#  Put modified vm_properties2.py and integration_preload_parameter2.py
#      in /tmp
#  ./ete-k8s2.sh onap <tag>
#
#################################################################
#################################################################
#################################################################
#################################################################

#
# Run the testsuite for the passed robot tag.
# Please clean up logs when you are done...
#
if [ "$1" == "" ] || [ "$2" == "" ]; then
   echo "Usage: ete-k8s2.sh [namespace] [tag]"
   exit
fi

set -x

export NAMESPACE="$1"

POD=$(kubectl --namespace $NAMESPACE get pods | sed 's/ .*//'| grep robot)


TAGS="-i $2"

if [ "$3" ]; then
	VARIABLES="-v $3"
fi

ETEHOME=/var/opt/ONAP
export GLOBAL_BUILD_NUMBER=$(kubectl --namespace $NAMESPACE exec  ${POD}  -- bash -c "ls -1q /share/logs/ | wc -l")
OUTPUT_FOLDER=$(printf %04d $GLOBAL_BUILD_NUMBER)_ete_$2
DISPLAY_NUM=$(($GLOBAL_BUILD_NUMBER + 90))

#VARIABLEFILES="-V /share/config/vm_properties.py -V /share/config/integration_robot_properties.py -V /share/config/integration_preload_parameters.py"
VARIABLEFILES="-V /tmp/vm_properties2.py -V /share/config/integration_robot_properties.py -V /tmp/integration_preload_parameters2.py"
VARIABLES="$VARIABLES -v GLOBAL_BUILD_NUMBER:$$"

kubectl --namespace $NAMESPACE exec ${POD} -- ${ETEHOME}/runTags.sh ${VARIABLEFILES} ${VARIABLES} -d /share/logs/${OUTPUT_FOLDER} ${TAGS} --display $DISPLAY_NUM
