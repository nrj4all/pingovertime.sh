#!/bin/bash
# DESCRIPTION:	Check and log if a host is reachable by ping

# DEFAULT CONFIGURATION
TESTS=5
PAUSE=1
TIMEOUT=2
LOGFILE=$0.log

# Display help
usage() {
	echo "USAGE:
		-a <IP> Host IP address - Required
		-c <count> Allowed failed pings - Default:" $TESTS"
		-p <duration> Pause between pings - Default:" $PAUSE "
		-t <timeout> Ping timeout - Default:" $TIMEOUT "
		-l <location> Logfile name - Default:" $LOGFILE "
		-h Display help"
	exit 0
}

log() {
	echo $1 > $LOGFILE
}

# PARAMETERS
[ $# -eq 0 ] && usage # Check for no parameters
while getopts "a:c:p:t:l:h" param; do
  case $param in
    a) IP=${OPTARG};; # IP of host
    c) TESTS=${OPTARG};; # How many failed pings before log
    p) PAUSE=${OPTARG};; # Duration between pings
	t) TIMEOUT=${OPTARG};; # Ping timeout
	l) LOGFILE=${OPTARG};; # Logfile location
	h | *) usage;; # Display help
  esac
done

# SCRIPT
log "`date` - Started PING monitoring of $IP (-c $TESTS -p $PAUSE -t $TIMEOUT )"
# Initialize
MISSED=0
# Infinite loop
while true; do
  # Check if ping is possible
  if ! ping -c 1 -w $TIMEOUT $IP > /dev/null; then
    # Increase failure counter
    ((MISSED++))
	# Print a x to screen
    echo -n "x"
  else
	# If failure counter greater then allowed missed pings
    if [ $MISSED -ge $TESTS ]; then
      log "`date` - $IP is up again after $MISSED missed pings."
    fi
    MISSED=0;
    echo -n "."
  fi
  if [ $MISSED -eq $TESTS ]; then
    log "`date` - $IP is down."
  fi
  sleep $PAUSE
done
