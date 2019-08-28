FROM ubuntu
## Be careful of Windows newlines

MAINTAINER "ONAP"

LABEL name="Docker image for the ONAP Robot Testing Framework"
LABEL usage="docker run -e ROBOT_TEST=<testname> -ti onapete"

ENV BUILDTIME=true

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
            python2.7 \
            python-dev \
            python-setuptools \
            python-wheel \
            python-pip \
            netbase \
            unzip \
            x11-utils \
            x11-xserver-utils \
            xvfb \
            xxd  \
            vim

# install python 3 after so it isn't default python version
RUN apt-get install \
        --no-install-recommends \
        --assume-yes \
            python3.7 \
            python3.7-dev \
            python3-pip

RUN pip install robotframework==3.1.2 \
    && python --version

# Copy the robot code
COPY . /var/opt/ONAP/
COPY lighttpd.conf /etc/lighttpd/lighttpd.conf
COPY authorization /etc/lighttpd/authorization
RUN chmod 777 /var/opt/ONAP/setup.sh \
    && chmod 777 /var/opt/ONAP/runTags.sh \
    && chmod 777 /var/opt/ONAP/dnstraffic.sh \
    && chmod 777 /var/opt/ONAP/runSoak.sh \
    && chmod 777 /var/opt/ONAP/runEteTag.sh \
    && chmod 600 /var/opt/ONAP/robot/assets/keys/* 

RUN cd /var/opt/ONAP \
    && ./setup.sh \
    && apt-get autoremove --assume-yes \
    && rm -rf /var/lib/apt/lists/*  \
    && apt-get clean

CMD ["lighttpd", "-D", "-f",  "/etc/lighttpd/lighttpd.conf"]



