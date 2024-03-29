#!/bin/bash
#
# setup : script to setup required runtime environment. This script can be run again to update anything
# this should stay in your project directory


# save console output in setup_<timestamp>.log file in project directory
timestamp=$(date +"%m%d%Y_%H%M%S")
LOG_FILE=setup_$timestamp.log
exec > >(tee -a ${LOG_FILE} )
exec 2> >(tee -a ${LOG_FILE} >&2)


# get the path
path=$(pwd)
pip install \
--no-cache-dir \
--exists-action s \
--target="$path/robot/library" \
'robotframework-seleniumlibrary==3.3.1' \
'robotframework-databaselibrary==1.2' \
'robotframework-angularjs==0.0.9' \
'robotframework-requests==0.5.0' \
'robotframework-sshlibrary==3.3.0' \
'robotframework-ftplibrary==1.6' \
'robotframework-archivelibrary==0.4.0' \
'robotframework-jsonlibrary==0.3.1'

# i dont why we need this, but lets protobuf work in docker
touch /var/opt/ONAP/robot/library/google/__init__.py

# Go back to execution folder
cd $path

# if the script is running during the image build skip the rest of it
# as required software is installed already.
if $BUILDTIME
then
	# we need to update PATH with chromium-chromedriver
	echo "Adding in-container chromedriver to PATH"
	ln -s /usr/lib/chromium-browser/chromedriver /usr/local/bin/chromedriver

	echo "Skipping desktop steps, building container image..."
else
	#
	# Get the appropriate chromedriver. Default to linux64
	#
	CHROMEDRIVER_URL=http://chromedriver.storage.googleapis.com/75.0.3770.140
	CHROMEDRIVER_ZIP=chromedriver_linux64.zip
	CHROMEDRIVER_TARGET=chromedriver.zip

	# Handle mac and windows
	OS=`uname -s`
	case $OS in
	  MINGW*_NT*)
	  	CHROMEDRIVER_ZIP=chromedriver_win32.zip
	  	;;
	  Darwin*)
	  	CHROMEDRIVER_ZIP=chromedriver_mac64.zip
	  	;;
	  *) echo "Defaulting to Linux 64" ;;
	esac

	if [ $CHROMEDRIVER_ZIP == 'chromedriver_linux64.zip' ]
	then
	    curl $CHROMEDRIVER_URL/$CHROMEDRIVER_ZIP -o $CHROMEDRIVER_TARGET
		unzip chromedriver.zip -d /usr/local/bin
	else
	    curl $CHROMEDRIVER_URL/$CHROMEDRIVER_ZIP -o $CHROMEDRIVER_TARGET
		unzip $CHROMEDRIVER_TARGET
	fi
	rm -rf $CHROMEDRIVER_TARGET
fi
