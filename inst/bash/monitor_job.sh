#!/bin/bash
#' ---
#' title: Monitor Jobs
#' date:  2020-09-22 11:03:32
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Seamless monitoring of long running jobs
#'
#' ## Description
#' Monitoring long running processes based on their result files, logfiles and top-dumps can be important and is done with this script.
#'
#' ## Details
#' The monitoring is done based on the listing, the number of lines and the tail output of the files to be monitored. Additional information
#' about the machine on which to job runs is obtained by the top-dump which can be generated using the option -t.
#'
#' ## Example
#' ./monitor_job.sh -r <result_file> -l <log_file>
#'
#' ## Set Directives
#' General behavior of the script is driven by the following settings
#+ bash-env-setting, eval=FALSE
set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  #  hence pipe fails if one command in pipe fails


#' ## Global Constants
#' ### Paths to shell tools
#+ shell-tools, eval=FALSE
ECHO=/bin/echo                             # PATH to echo                            #
DATE=/bin/date                             # PATH to date                            #
MKDIR=/bin/mkdir                           # PATH to mkdir                           #
BASENAME=/usr/bin/basename                 # PATH to basename function               #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #

#' ### Directories
#' Installation directory of this script
#+ script-directories, eval=FALSE
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of bashtools on host   #

#' ### Files
#' This section stores the name of this script and the
#' hostname in a variable. Both variables are important for logfiles to be able to
#' trace back which output was produced by which script and on which server.
#+ script-files, eval=FALSE
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
SERVER=`hostname`                          # put hostname of server in variable      #



#' ## Functions
#' The following definitions of general purpose functions are local to this script.
#'
#' ### Usage Message
#' Usage message giving help on how to use the script.
#+ usg-msg-fun, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -l <log_file> -r <result_file> -n <number_lines_tail> -s <sleep_seconds> -t"
  $ECHO "  where -l <log_file>           --  path to log file"
  $ECHO "        -r <result_file>        --  path to result file"
  $ECHO "        -n <number_lines_tail>  --  number of lines shown in tail output  (optional) ..."
  $ECHO "        -s <sleep_seconds>      --  seconds to sleep between loops        (optional) ..."
  $ECHO "        -t                      --  show a top dump of the machine        (optional) ..."
  $ECHO ""
  exit 1
}

#' ### Start Message
#' The following function produces a start message showing the time
#' when the script started and on which server it was started.
#+ start-msg-fun, eval=FALSE
start_msg () {
  $ECHO "********************************************************************************"
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "Server:  $SERVER"
  $ECHO
}

#' ### End Message
#' This function produces a message denoting the end of the script including
#' the time when the script ended. This is important to check whether a script
#' did run successfully to its end.
#+ end-msg-fun, eval=FALSE
end_msg () {
  $ECHO
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "********************************************************************************"
}

#' ### Log Message
#' Log messages formatted similarly to log4r are produced.
#+ log-msg-fun, eval=FALSE
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}

#' ### Monitor File
#' The given file is monitored based on the listing created by `ls`, the number
#' of lines obtained by `wc -l` and the tail of the file to be monitored.
#+ monitor-file-fun
monitor_file () {
  local l_MFILE=$1

  log_msg 'monitor_file' " ** Listing of $l_MFILE ..."
  ls -l $l_MFILE

  log_msg 'monitor_file' " ** Number of lines in $l_MFILE ..."
  wc -l $l_MFILE

  log_msg 'monitor_file' " ** Tail output for $l_MFILE ..."
  tail -n $NRLTAIL $l_MFILE
  echo
}


#' ## Main Body of Script
#' The main body of the script starts here.
#+ start-msg, eval=FALSE
start_msg

#' ## Getopts for Commandline Argument Parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing, eval=FALSE
LOGFILE=""
RESULTFILE=""
NRLTAIL="10"
SLEEPSEC="60"
TOPDUMP='false'
while getopts ":l:r:n:s:th" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    l)
      LOGFILE=$OPTARG
      ;;
    r)
      RESULTFILE=$OPTARG
      ;;
    n)
      NRLTAIL=$OPTARG
      ;;
    s)
      SLEEPSEC=$OPTARG
      ;;
    t)
      TOPDUMP='true'
      ;;
    :)
      usage "-$OPTARG requires an argument"
      ;;
    ?)
      usage "Invalid command line argument (-$OPTARG) found"
      ;;
  esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.



#' ## Monitoring Components
#' The different monitoring components consist of a logfile, a resultfile,
#' the tail-output. These components are all produced by the function `monitor_file`.
#' If specified, a top-dump of the machine where the job runs is produced and shown.
#+ monitoring files
while [ TRUE ]
do
if [ "$TOPDUMP" == 'true' ]
then
  top -b -n1 > top_dump.txt
  head -$(nproc) top_dump.txt
  rm top_dump.txt
fi
if [ "$LOGFILE" != "" ]
then
  log_msg "$SCRIPT" " * Monitoring logfile: $LOGFILE ..."
  monitor_file $LOGFILE
fi
if [ "$RESULTFILE" != "" ]
then
  log_msg "$SCRIPT" " * Monitoring resultfile: $RESULTFILE ..."
  monitor_file $RESULTFILE
fi
sleep $SLEEPSEC
done



#' ## End of Script
#' Print an End-of-script message
#+ end-msg, eval=FALSE
end_msg

