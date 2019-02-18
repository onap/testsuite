FROM ubuntu
## Be careful of Windows newlines

MAINTAINER "ONAP"

LABEL name="Docker image for the ONAP Robot Testing Framework"
LABEL usage="docker run -e ROBOT_TEST=<testname> -ti openecompete"

# Install Python Pip, Robot framework, firefox, lighttpd web server, wget
# Restructuring so we can see where it fails in the build.
RUN apt-get update
RUN apt-get --assume-yes install python2.7
RUN apt-get --assume-yes install build-essential
RUN apt-get --assume-yes install dbus
RUN apt-get --assume-yes install dnsutils
RUN apt-get --assume-yes install git
RUN apt-get --assume-yes install libappindicator1
RUN apt-get --assume-yes install libffi-dev
RUN apt-get --assume-yes install libindicator7
RUN apt-get --assume-yes install libssl-dev
RUN apt-get --assume-yes install libxss1
RUN apt-get --assume-yes install lighttpd
RUN apt-get --assume-yes install net-tools
RUN apt-get --assume-yes install python-dev
RUN apt-get --assume-yes install python-pip
RUN apt-get --assume-yes install unzip
RUN apt-get --assume-yes install wget
RUN apt-get --assume-yes install xvfb
RUN apt-get --assume-yes install xxd
RUN pip install --upgrade pip
RUN pip install robotframework==3.0.4
RUN python --version

# Install chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list  && \
    apt-get update && \
    apt-get --assume-yes install google-chrome-stable

# Copy the robot code
COPY / /var/opt/ONAP/
COPY lighttpd.conf /etc/lighttpd/lighttpd.conf
COPY authorization /etc/lighttpd/authorization
RUN chmod 777 /var/opt/ONAP/setup.sh && \
    chmod 777 /var/opt/ONAP/runTags.sh && \
    chmod 777 /var/opt/ONAP/dnstraffic.sh && \
    chmod 777 /var/opt/ONAP/runSoak.sh && \
    chmod 777 /var/opt/ONAP/runEteTag.sh

# Set mode for the SSH keys
RUN chmod 600 /var/opt/ONAP/robot/assets/keys/* 

# Update the ssh library so that it will run properly in the docker env
RUN cd /var/opt/ONAP && ./setup.sh && apt-get clean

CMD ["lighttpd", "-D", "-f",  "/etc/lighttpd/lighttpd.conf"]



