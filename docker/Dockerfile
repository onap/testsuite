FROM ubuntu
## Be careful of Windows newlines

MAINTAINER "OpenECOMP"

LABEL name="Docker image for the OpenECOMP End-to-End Robot Framework"
LABEL usage="docker run -e ROBOT_TEST=<testname> -ti openecompete"

# Install Python Pip, Robot framework, firefox, lighttpd web server, wget
RUN apt-get update && \
    apt-get --assume-yes install python=2.7.11-1 && \
    apt-get --assume-yes install python-pip dbus xvfb lighttpd wget git net-tools dnsutils unzip && \
    apt-get --assume-yes install libxss1 libappindicator1 libindicator7 build-essential libssl-dev libffi-dev python-dev && \
    pip install --upgrade pip && \
    pip install robotframework  && \
    python --version
    
# Install chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list  && \
    apt-get update && \
    apt-get --assume-yes install google-chrome-stable

# Copy the robot code
COPY OpenECOMP_ETE/ /var/opt/OpenECOMP_ETE/
COPY lighttpd.conf /etc/lighttpd/lighttpd.conf      
RUN chmod 777 /var/opt/OpenECOMP_ETE/setup.sh
RUN chmod 777 /var/opt/OpenECOMP_ETE/runTags.sh
RUN chmod 777 /var/opt/OpenECOMP_ETE/dnstraffic.sh

# Update the ssh library so that it will run properly in the docker env
RUN cd /var/opt/OpenECOMP_ETE && ./setup.sh
RUN apt-get clean

CMD ["lighttpd", "-D", "-f",  "/etc/lighttpd/lighttpd.conf"]



