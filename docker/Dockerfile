FROM ppodgorsek/robot-framework:latest
	
MAINTAINER "ONAP"

LABEL name="Docker image for the ONAP Robot Testing Framework. Extension of ppodgorsek/robot-framework to add a few packages"
LABEL usage="docker run -e ROBOT_TEST=<testname> -ti onapete"

# Install Packages not installed by base image
RUN apk --no-cache add \
        git \
        bind-tools

#install all the robot framework libraries and needed libraries beyond what is installed by the base image
RUN pip3 install \
    --no-cache-dir \
    --exists-action s \
    'robotframework-angularjs==0.0.9 '  \
    'robotframework-archivelibrary==0.4.0' \
    && pip3 install \
    --pre \
    --no-cache-dir \
    --exists-action s \
    --extra-index-url="https://nexus3.onap.org/repository/PyPi.staging/simple" \
    'robotframework-onap==0.6.0.*' \
    && python --version

# i dont why we need this, but lets protobuf work in docker
RUN touch /usr/local/lib/python3.7/site-packages/google/__init__.py

#copy our run script to the proper directory
COPY run.sh /opt/robotframework/bin/run.sh
RUN chmod +x /opt/robotframework/bin/run.sh

# set this script as our entrypoint
ENTRYPOINT ["/opt/robotframework/bin/run.sh"]
