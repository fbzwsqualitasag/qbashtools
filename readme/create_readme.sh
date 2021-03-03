#!/bin/bash
#' ---
#' title: Create Project README
#' date:  2021-01-19 16:49:52
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Seamless creation of README-file
#'
#' ## Description
#' Create a README file for a project under data_projekte/projekte
#'
#' ## Details
#' Based on a template, the required information are asked at the command-line and are inserted into the resulting README-file
#'
#' ## Example
#' ./create_readme.sh -p <project_name>
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
  $ECHO "Usage: $SCRIPT -p <project_name> -t <template_path> -v"
  $ECHO "  where -p <project_dir>    --  (optional) specify the project directory ..."
  $ECHO "        -t <template_path>  --  (optional) specify path to template file"
  $ECHO "        -v                  --  (optional) produce verbose output"
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

#' ### Collect Tags
#' Tags following a certain regex are collected
#+ get-tags-from-template-fun
get_tags_from_template () {
  local l_TMPLPATH=$1
  local l_REGEXTAG='__[A-Z_]*__'
  if [ "$VERBOSE" == 'TRUE' ]
  then
    log_msg 'get_tags_from_template' " ** Start extracting tags from $l_TMPLPATH ...";
  fi
  while read tag
  do
    if [ "$VERBOSE" == 'TRUE' ];then log_msg 'get_tags_from_template' " ** Adding tag: $tag ...";fi
    tags+=("${tag}")
  done < <(grep -o "$l_REGEXTAG" $l_TMPLPATH | sort -u)

}

#' ### Setting Default for Tag
#' For some tags, we want to provide useful default values
#+ set-default-fun
set_default_for_tag () {
  local l_TAG=$1
  # project name
  if [ "$l_TAG" == '__PROJECTNAME__' ]
  then
    DEFAULTVALUE=$(basename $PROJECTNAME)
  fi
  # version
  if [ "$l_TAG" == '__VERSION__' ]
  then
    DEFAULTVALUE='0.0.0.900'
  fi
  # StartDate:
  if [ "$l_TAG" == '__STARTDATE__' ]
  then
    DEFAULTVALUE=$(date +"%Y%m%d")
  fi

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
TEMPLATEPATH=/qualstorzws01/data_projekte/linuxBin/bashtools/template/readme/README.template
PROJECTDIR=/qualstorzws01/data_projekte/projekte
CURWD=$(pwd)
PROJECTNAME=$(basename $CURWD)
VERBOSE='FALSE'
while getopts ":p:t:vh" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    p)
      PROJECTNAME=$OPTARG
      ;;
    t)
      TEMPLATEPATH=$OPTARG
      ;;
    v)
      VERBOSE='TRUE'
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


#' ## Project Path Settings
#' In case the value given by $PROJECTNAME is not a directory, then the project
#' path is set using the value of $PROJECTDIR
#+ proj-path-setting
if [ -d "$PROJECTNAME" ]
then
  PROJECTPATH=$PROJECTNAME
else
  PROJECTPATH=${PROJECTDIR}/$PROJECTNAME
fi
log_msg "$SCRIPT" " * Setting project path to: $PROJECTPATH ..."


#' ## Checks for Variables and Arguments
#' The following statements are used to check whether required arguments
#' and required variables are defined with meaningful values. This includes
#' checks for directories and files that must exist.
#+ var-arg-test, eval=FALSE
if [ ! -d "$PROJECTPATH" ]
then
  usage " *** CANNOT FIND project path: $PROJECTPATH ... ==> Create it first ..."
fi
if [ ! -f "$TEMPLATEPATH" ]
then
  usage " *** CANNOT FIND template file under: $TEMPLATEPATH"
fi


#' ## Produce Output File
#' The file that is used as output (README) is generated
#+ produce-output
TEMPLATEFILE=$(basename $TEMPLATEPATH)
log_msg "$SCRIPT" " * Template file: $TEMPLATEFILE ..."
OUTPUTFILE=$(echo $TEMPLATEFILE | sed -e 's/\.template//')
OUTPUTPATH=${PROJECTPATH}/$OUTPUTFILE


#' ## Copy Template
#' The template for the README is copied to the project path
#+ copy-template
log_msg "$SCRIPT" " * Copy template from: $TEMPLATEPATH to $OUTPUTPATH ..."
cp $TEMPLATEPATH $OUTPUTPATH


#' ## Collecting Tags
#' The tags in the template file are collected into an array
#+ collect-tags
# initialise tags array
tags=()
get_tags_from_template $OUTPUTPATH
if [ "$VERBOSE" == 'TRUE' ]
then
  log_msg "$SCRIPT" ' * List of tags extracted ...'
  for i in ${tags[@]}
  do
    log_msg "$SCRIPT" " * Tag: $i ..."
  done
fi


#' ## Ask User for Input
#' The users are asked for input
#+ ask-user
for i in ${tags[@]}
do
  if [ "$VERBOSE" == 'TRUE' ];then log_msg $SCRIPT " * Process tag: $i ...";fi
  # check for defaults
  DEFAULTVALUE=''
  set_default_for_tag $i
  # read input from command line
  read -p "$i [$DEFAULTVALUE]: " inputvalue
  if [ -z "$inputvalue" ]
  then
    replacevalue=$DEFAULTVALUE
  else
    replacevalue=$inputvalue
  fi
  if [ "$VERBOSE" == 'TRUE' ];then log_msg $SCRIPT " * Replacement value: $replacevalue ...";fi
  # replace the tag in $i with $replacevalue
  sed "s#$i#$replacevalue#g" < $OUTPUTPATH  > $OUTPUTPATH.new
  # rename
  mv $OUTPUTPATH.new $OUTPUTPATH
  # check for empty e-mail addresses
  if [ $(grep '<>' $OUTPUTPATH | wc -l) -gt 0 ]
  then
    if [ "$VERBOSE" == 'TRUE' ];then log_msg $SCRIPT " * Remove empty e-mail address field ...";fi
    sed "s/<>//" < $OUTPUTPATH  > $OUTPUTPATH.new
    # rename
    mv $OUTPUTPATH.new $OUTPUTPATH
  fi
done



#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

