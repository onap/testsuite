FROM ubuntu:20.04 AS base

## Be careful of Windows newlines
LABEL name="Docker image for the ONAP Robot Testing Framework"
LABEL usage="docker run -e ROBOT_TEST=<testname> -ti onapete"
ENV BUILDTIME=true
ENV DEBIAN_FRONTEND=noninteractive

ARG KUBERNETES_VERSION="v1.23.8"
ARG HELM_VERSION="v3.8.2"

ARG PYTHON_UTILS_REPO=git.onap.org/testsuite/python-testing-utils.git
ARG PYTHON_UTILS_TAG=master

ARG DEMO_REPO=git.onap.org/demo
ARG DEMO_TAG=master

# Install apt packages, Python, Pip, etc
RUN apt-get update &&  \
    apt-get install --no-install-recommends --assume-yes  \
    chromium-browser  \
    chromium-chromedriver  \
    dnsutils  \
    git  \
    gcc  \
    libffi-dev  \
    libssl-dev  \
    lighttpd  \
    make  \
    net-tools  \
    netbase  \
    unzip  \
    zip  \
    x11-utils  \
    x11-xserver-utils  \
    xvfb  \
    xxd  \
    wget  \
    vim  \
    python3.8  \
    python3.8-dev  \
    python3-pip &&  \
    ln -s /usr/bin/python3 /usr/bin/python && \
    apt-get autoremove --assume-yes &&  \
    rm -rf /var/lib/apt/lists/* &&  \
    apt-get clean

# Get kubectl
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
# Get helm
ADD https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 get_helm.sh

COPY requirements.txt requirements.txt

RUN mkdir -p /var/opt/ONAP &&  \
    pip3 install --no-cache-dir -r requirements.txt setuptools wheel virtualenv &&  \
    git clone --depth 1 https://$DEMO_REPO -b $DEMO_TAG /var/opt/ONAP/demo &&  \
    chmod +x /usr/local/bin/kubectl &&  \
    chmod 700 get_helm.sh &&  \
    ./get_helm.sh --version $HELM_VERSION


COPY html/ /var/opt/ONAP/html
COPY robot/ /var/opt/ONAP/robot
COPY *.sh /var/opt/ONAP/
COPY docker/lighttpd.conf /etc/lighttpd/lighttpd.conf
COPY docker/authorization /etc/lighttpd/authorization

RUN mkdir -p /app &&  \
    cp /var/opt/ONAP/setup-hvves.sh /app &&  \
    chmod 600 /var/opt/ONAP/robot/assets/keys/* &&  \
    chmod 777 /var/opt/ONAP/*.sh &&  \
    cd /var/opt/ONAP &&  \
    ./setup.sh

CMD ["lighttpd", "-D", "-f",  "/etc/lighttpd/lighttpd.conf"]
