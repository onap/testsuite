FROM ubuntu:18.04

## Be careful of Windows newlines
MAINTAINER "ONAP"
LABEL name="Docker image for the ONAP Robot Testing Framework"
LABEL usage="docker run -e ROBOT_TEST=<testname> -ti onapete"
ENV BUILDTIME=true

ARG TESTSUITE_TAG=master
ARG HEATBRIDGE_TAG=master
ARG PYTHON_UTILS_TAG=master
ARG DEMO_TAG=master
ARG KUBERNETES_VERSION="v1.15.11"


ARG TESTSUITE_REPO=git.onap.org/testsuite
ARG HEATBRIDGE_REPO=git.onap.org/testsuite/heatbridge.git
ARG PYTHON_UTILS_REPO=git.onap.org/testsuite/python-testing-utils.git
ARG DEMO_REPO=git.onap.org/demo

COPY requirements.txt requirements.txt

# Install kubectl
# Note: Latest version may be found on:
# https://aur.archlinux.org/packages/kubectl-bin/
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl

# Install Python, Pip, Robot framework, chromium, lighttpd web server
RUN apt-get update \
    && apt-get install \
        --no-install-recommends \
        --assume-yes \
            chromium-browser \
            chromium-chromedriver \
            dnsutils \
            git \
            gcc \
            libffi-dev \
            libssl-dev \
            lighttpd \
            make \
            net-tools \
            python2.7 python-dev python-setuptools python-wheel python-pip \
            netbase \
            unzip zip \
            x11-utils x11-xserver-utils \
            xvfb \
            xxd  \
            wget vim  \
            python3.7 python3.7-dev python3-pip && \
    mkdir -p /var/opt/ONAP && \
    pip install -r requirements.txt && \
    pip install --no-cache-dir \
    git+https://$HEATBRIDGE_REPO@$HEATBRIDGE_TAG#egg=heatbridge\&subdirectory=heatbridge \
    git+https://$PYTHON_UTILS_REPO@$PYTHON_UTILS_TAG#egg=robotframework-onap\&subdirectory=robotframework-onap && \
    git clone --depth 1 https://$TESTSUITE_REPO -b $TESTSUITE_TAG /var/opt/ONAP && \
    git clone --depth 1 https://$DEMO_REPO -b $DEMO_TAG /var/opt/ONAP/demo && \
    chmod +x /usr/local/bin/kubectl

RUN python3.7 -m pip install setuptools wheel
RUN python3.7 -m pip install virtualenv

# Copy the robot code
RUN mkdir -p /etc/lighttpd && \
    rm /etc/lighttpd/lighttpd.conf && \
    ln -s /var/opt/ONAP/docker/lighttpd.conf /etc/lighttpd/lighttpd.conf && \
    ln -s /var/opt/ONAP/docker/authorization /etc/lighttpd/authorization && \
    chmod 777 /var/opt/ONAP/setup.sh \
    && chmod 777 /var/opt/ONAP/runTags.sh \
    && chmod 777 /var/opt/ONAP/dnstraffic.sh \
    && chmod 777 /var/opt/ONAP/runSoak.sh \
    && chmod 777 /var/opt/ONAP/runEteTag.sh \
    && chmod 600 /var/opt/ONAP/robot/assets/keys/* && \
    cd /var/opt/ONAP && ./setup.sh \
    && apt-get autoremove --assume-yes \
    && rm -rf /var/lib/apt/lists/*  \
    && apt-get clean
CMD ["lighttpd", "-D", "-f",  "/etc/lighttpd/lighttpd.conf"]
