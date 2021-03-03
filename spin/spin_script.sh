#!/bin/bash
#' ---
#' title: Spin Bash Script to Rmd
#' date:  "`r Sys.Date()`"
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Documentation is an important part of any piece of software. Creating documentation
#' and keeping documentation up-to-date takes time and is often not at the top of
#' the priority list. The solution to this problem is made easier when the creation
#' of the documentation is as seamless as possible. This script provides the possiblity
#' to create short pieces of documenation inside of a bash script. This documenation
#' can then be converted into an HTML page using the Rmarkdown package behind the
#' scenes.
#'
#' ## Description
#' This script works on the assumption that every bash script consists of two parts.
#'
#' 1. Lines starting with `#'` are understood as comments for the script, but will
#'    be converted into markdown text by this script.
#' 2. Any lines not starting with `#'` is understood as bash code. Chunks of bash
#'    code start with a line that starts with `#+` which allows to specify some
#'    options that determine how the code is treated.
#'
#' For more information about the functionality of this script, please have a
#' look at the corresponding vignette.
#'
#' ## Example
#' The following example shows how to generate an html-page (spin) based on a
#' specially formatted bash script.
#' `bash_script_so.template`.
#' ```
#' ./bash/spin_script.sh -s my_new_bash_script.sh
#' ```
#'
#' The easiest way how to get to a bash script that can be converted into an
#' html-document is to use `new_bash_script.sh` to created the new bash-script.
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
BASENAME=/usr/bin/basename                 # PATH to basename function               #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #

#' ### Directories
#+ script-directories, eval=FALSE
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of bashtools on host   #

#' ### Files
#+ script-files, eval=FALSE
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
SERVER=`hostname`                          # put hostname of server in variable      #



#' ## Functions
#' In this section user-defined functions that are specific for this script are
#' defined in this section.
#'
#' * title: Show usage message
#' * param: message that is shown
#+ usg-msg-func, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -s <script_path> -o <out_file> -f <out_format>"
  $ECHO "  where -s <script_path>  --  path to input script"
  $ECHO "        -o <out_file>     --  name of output file"
  $ECHO "        -f <out_format>   --  can be changed to pdf, o/w html is used"
  $ECHO ""
  exit 1
}

#' ## Start Message
#' Message specifying the beginning of the script
#+ start-msg-func, eval=FALSE
start_msg () {
  $ECHO "********************************************************************************"
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "Server:  $SERVER"
  $ECHO
}

#' ## End Message
#' Produce a message denoting the end of the script
#+ end-msg-func, eval=FALSE
end_msg () {
  $ECHO
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "********************************************************************************"
}

#' ## Logging Function
#' Standardized way of producing a log message similar to log4r.
#+ log-msg-func, eval=FALSE
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}


#' ## Main Body of Script
#' The main body of the script starts here.
#+ start-msg, eval=FALSE
start_msg

#' ## Getopts for Commandline Argument Parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing
SCRIPTPATH=""
OUTFILE=""
OUTFORMAT="html_document"
while getopts ":f:s:o:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    f) # specify a format, when given pdf, use pdf, o/w use html
      if [ "$OPTARG" == "pdf"];then
        OUTFORMAT="pdf_document"
      fi
      ;;
    s)
      if test -f $OPTARG; then
        SCRIPTPATH=$OPTARG
      else
        usage "$OPTARG isn't a regular file"
      fi
      ;;
    o)
      OUTFILE=$OPTARG
      ;;
    c)
      c_example="c_example_value"
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

#' ## Checks for Command Line Arguments
#' The following statements are used to check whether required arguments
#' have been assigned with a non-empty value
#+ argument-test
if test "$SCRIPTPATH" == ""; then
  usage "-s <script_path> not defined"
fi


#' ## Pre-requisites
#' For this script to work, the R-package `qgert` must be installed. If the
#' package is available, it is installed by the following statement.
#+ pkg-install, eval=FALSE
R -e "if (!'qgert' %in% installed.packages()) devtools::install_github('pvrqualitasag/qgert', upgrade = 'always')" --no-save

#' ## Call the spin function in R
#' Depending on whether an output file is specified the R-function `spin_sh` is
#' called on the input script.
#+ spin-sh-call
if [ "$OUTFILE" == "" ]
then
  R -e "qgert::spin_sh(ps_sh_hair = '$SCRIPTPATH', pobi_output_format = '$OUTFORMAT')" --no-save
else
  R -e "qgert::spin_sh(ps_sh_hair = '$SCRIPTPATH', ps_out_rmd = '$OUTFILE', pobi_output_format = '$OUTFORMAT')" --no-save
fi


#' ## End of Script
#+ end-msg
end_msg




