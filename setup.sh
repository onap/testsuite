#!/bin/bash
#
# setup : script to setup required runtime environment. This script can be run again to update anything
# this should stay in your project directory
#

# get the path
path=$(pwd)

pip install --no-cache-dir --target="$path/robot/library" 'selenium<=3.0.0' 'requests==2.11.1' 'robotframework-selenium2library==1.8.0' \
'robotframework-databaselibrary==0.8.1' 'robotframework-extendedselenium2library==0.9.1' 'robotframework-requests==0.4.5' \
'robotframework-sshlibrary==2.1.2' \
'robotframework-sudslibrary==0.8' 'robotframework-ftplibrary==1.3' 'robotframework-rammbock==0.4.0.1' \
'deepdiff==2.5.1' 'dnspython==1.15.0' 'robotframework-httplibrary==0.4.2' 'robotframework-archivelibrary==0.3.2' 'PyYAML==3.12'


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
pip install --no-cache-dir --upgrade --target="$path/robot/library" .


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
pip install --no-cache-dir --upgrade --target="$path/robot/library" .


# NOTE: Patch to incude explicit install of paramiko to 2.0.2 to work with sshlibrary 2.1.2
# This should be removed on new release of paramiko (2.1.2) or sshlibrary
# https://github.com/robotframework/SSHLibrary/issues/157
pip install --no-cache-dir --target="$path/robot/library" -U 'paramiko==2.0.2'

#
# Get the appropriate chromedriver. Default to linux64
#
CHROMEDRIVER_URL=http://chromedriver.storage.googleapis.com/2.27
CHROMEDRIVER_ZIP=chromedriver_linux64.zip

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
    wget -O chromedriver.zip $CHROMEDRIVER_URL/$CHROMEDRIVER_ZIP
	unzip chromedriver.zip -d /usr/local/bin
else
    curl $CHROMEDRIVER_URL/$CHROMEDRIVER_ZIP -o chromedriver.zip
	unzip chromedriver.zip
fi
