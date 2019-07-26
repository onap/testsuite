#!/bin/bash
#
# This script is run by the policy closed loop to generate traffic (DNS packets) to the DNS
#
#           Usage:    dnstraffic.sh  <DNSIP> <RATE_PER_SEC> <ITERATIONS>
#
# The DNSIP is that of the DNS vLoadBalancer.
# The RATE_PER_SEC is the approximate number of nslookup requests generated per second.
# The ITERATIONS is roughly the number of seconds to run the test. Note that the Robot 
# will kill this script after the validation is complete.
#  
# The validation portion of the script has done a successful lookup, so the point of 
# these requests is to generate DNS packets. We do not care about the results. The timeout
# of 1 second is to ensure we do not flood the process table with long waits 
# on failed lookups.
# 
# We generate an approximate rate because we sleep for a full second so the RATE_PER_SEC 
# should have some slop in it. We only need to drive this to 20+ per second, so a 35 
# per second should fall within the range to trigger the polciy check and prvide enough
# to validate even distribution without spawning a 3rd DNS
#
DNSIP=$1
RATE_PER_SEC=$2
ITERATIONS=$3
ITERATIONS=${ITERATIONS:-300}

for iter in `seq 1 $ITERATIONS`;
do
   for i in `seq 1 $RATE_PER_SEC`;
   do
        nslookup -timeout=1 host2.dnsdemo.onap.org $DNSIP >/dev/null 2>&1 &
   done
   sleep 1
done
