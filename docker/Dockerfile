FROM ubuntu
## Be careful of Windows newlines

MAINTAINER "OpenECOMP"

LABEL name="Docker image for the OpenECOMP Robot Testing Framework"
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
RUN pip install --upgrade pip
RUN pip install robotframework
RUN python --version

# Install chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list  && \
    apt-get update && \
    apt-get --assume-yes install google-chrome-stable

# Copy the robot code
COPY / /var/opt/OpenECOMP_ETE/
COPY lighttpd.conf /etc/lighttpd/lighttpd.conf
RUN chmod 777 /var/opt/OpenECOMP_ETE/setup.sh && \
    chmod 777 /var/opt/OpenECOMP_ETE/runTags.sh && \
    chmod 777 /var/opt/OpenECOMP_ETE/dnstraffic.sh && \
    chmod 777 /var/opt/OpenECOMP_ETE/runSoak.sh && \
    chmod 777 /var/opt/OpenECOMP_ETE/runEteTag.sh

# Update the ssh library so that it will run properly in the docker env
RUN cd /var/opt/OpenECOMP_ETE && ./setup.sh && apt-get clean

CMD ["lighttpd", "-D", "-f",  "/etc/lighttpd/lighttpd.conf"]



