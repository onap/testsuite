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
'selenium<=3.0.0' \
'robotframework-selenium2library==1.8.0' \
'robotframework-databaselibrary==0.8.1' \
'robotframework-extendedselenium2library==0.9.1' \
'robotframework-requests==0.5.0' \
'robotframework-sshlibrary==2.1.2' \
'robotframework-sudslibrary==0.8' \
'robotframework-ftplibrary==1.3' \
'robotframework-rammbock==0.4.0.1' \
'robotframework-httplibrary==0.4.2' \
'robotframework-archivelibrary==0.3.2' \
'robotframework-kafkalibrary==0.0.2'


# get the git for the eteutils you will need to add a private key to your ssh before this
if [ -d $path/testsuite/eteutils ]
then
    # Support LF build location
	cd $path/testsuite/eteutils
else
	cd ~
	git config --global http.sslVerify false
	if [ -d ~/python-testing-utils ]
	then
		cd python-testing-utils
		git pull origin master
	else
		git clone https://gerrit.onap.org/r/testsuite/python-testing-utils.git
		cd python-testing-utils
	fi
fi

pip install \
--no-cache-dir \
--upgrade \
--exists-action s \
--target="$path/robot/library" ./robotframework-onap


if [ -d $path/testsuite/heatbridge ]
then
    # Support LF build location
	cd $path/testsuite/heatbridge
else
	cd ~
	git config --global http.sslVerify false
	if [ -d ~/heatbridge ]
	then
		cd heatbridge
		git pull origin master
	else
		git clone https://gerrit.onap.org/r/testsuite/heatbridge.git
		cd heatbridge
	fi
fi

pip install \
--no-cache-dir \
--upgrade \
--exists-action s \
--target="$path/robot/library" \
./heatbridge


# NOTE: Patch to incude explicit install of paramiko to 2.0.2 to work with sshlibrary 2.1.2
# This should be removed on new release of paramiko (2.1.2) or sshlibrary
# https://github.com/robotframework/SSHLibrary/issues/157
pip install \
--no-cache-dir \
--target="$path/robot/library" \
-U 'paramiko==2.0.2'


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
	CHROMEDRIVER_URL=http://chromedriver.storage.googleapis.com/2.43
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

#
# Install kafkacat : https://github.com/edenhill/kafkacat
#
OS=`uname -s`
case $OS in
	Darwin)
		brew install kafkacat ;;
	Linux)
		apt-get -y install kafkacat
esac
#
# Install protobuf
#
OS=`uname -s`
case $OS in
        Darwin)
                brew install protobuf ;;
        Linux)
                apt-get -y install protobuf-compiler
esac
