#!/bin/bash
#' ---
#' title: Create New Bash Script
#' date:  2018-08-09
#' author: pvr
#' ---
#' ## Purpose
#' A new script is created from a class of different templates. The templates reflect
#' different scripting styles from different persons or different purposes for the
#' final script.
#'
#' ## Description
#' The template specified on the commandline with the `-t` option is read and placeholders
#' are extracted. The script asks the user interactively for the value with which the
#' placeholders should be replaced. The result after the replacement is written to
#' an output file that can either be specified or that is generated based on the current
#' date and time.
#'
#' ## Example
#' The following example shows how to create a new bash script using the template
#' `bash_script_so.template`.
#' ```
#' ./bash/new_bash_script.sh -t templates/bash/bash_script_so.template -o my_new_bash_script.sh
#' ```

#' ## Global Constants
#' ### Paths to shell tools
#+ shell-tools, eval=FALSE
# prog paths                               #                                         #
BASENAME=/usr/bin/basename                 # PATH to basename function               #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #
SED=`which sed`                            # PATH to sed                             #
WHOAMI=/usr/bin/whoami                     # PATH to whoami                          #
DATE=/bin/date                             # PATH to date                            #
CP=/bin/cp                                 # PATH to cp                              #
MV=/bin/mv                                 # PATH to mv                              #
CHMOD=/bin/chmod                           # PATH to chmod                           #

#' ### Directories
#+ script-directories, eval=FALSE
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of this script         #
BASHTOOLDIR=`$DIRNAME $INSTALLDIR`         # directory of bashtools on host          #
UTILDIR=$INSTALLDIR                 # directory containing utilities          #
TEMPLATEDIR=$BASHTOOLDIR/template          # directory containing templates          #

#' ### Files
#+ script-files, eval=FALSE
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #


#' ###  Utilities
#' A set of functions that can be used in different scripts are sourced from a
#' utilities script.
UTIL=$UTILDIR/bash_utils.sh
source $UTIL

#' ### Other Constants
TEMPLATEPATH=$TEMPLATEDIR/bash/bash_script_so.template
GETTAGSCRIPT=$UTILDIR/get_template_tags.sh
OUTPUTPATH=`$DATE +"%Y%m%d%H%M%S"`_new_script.sh
DEFAULTSCRIPTRIGHT=755

#' ### Defaults for tags
#' Tags are used in templates to indicate where placeholders are and where
#' values must be inserted. For some values, we can come up with reasonable
#' defaults.
STARTDATE=`$DATE +"%Y-%m-%d %H:%M:%S"`
AUTHORABBREV=`$WHOAMI`
AUTHORNAME=`$WHOAMI`


#' ## Functions
#' In this section user-defined functions that are specific for this script are
#' defined in this section.


#' ## Main Body of Script
#' The main body of the script starts here.
#+ start-msg, eval=FALSE
start_msg $SCRIPT


#' ## Getopts for Commandline Argument Parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing, eval=FALSE
QUIET=FALSE
VERBOSE=FALSE
while getopts :o:qt:vh FLAG; do
  case $FLAG in
    o) # set option -o to specify output file
      OUTPUTPATH=$OPTARG
      ;;
    q) # set option -s to run in silent mode without tag replacement
      QUIET=TRUE
      ;;
    t) # set option "-t"  to specify the template file
      TEMPLATEPATH=$OPTARG
	    ;;
	  v)
	    VERBOSE=TRUE
	    ;;
	  h) # option -h shows usage
  	  usage $SCRIPT "Help message" "$SCRIPT -t <template_file>"
	    ;;
	  *) # invalid command line arguments
	    usage $SCRIPT "Invalid command line argument $OPTARG" "$SCRIPT -o <output_file> -t <template_file>"
	    ;;
  esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.



#' ## Definition of Output Directory
#' If output directory is not the cwd, and it does not exist, create it
#+ output-dir-check-create
OUTPUTDIR=`$DIRNAME $OUTPUTPATH`
if [ "$OUTPUTDIR" != "." ]
then
  check_exist_dir_create $OUTPUTDIR
fi


#' ## Checking prerequisits
#' Templates and the script to extract tags are required for this script to run
#+ check-prereq
check_exist_file_fail $TEMPLATEPATH
check_exist_file_fail $GETTAGSCRIPT


#' ## Copy Template to Output
#' Set the template to be the first version of the output
#+ cp-templ-script
$CP $TEMPLATEPATH $OUTPUTPATH


#' ## Silent Mode
#' In case, we are in silent mode, we stop here, no tag replacement is done
#+ silent-mode
if [ "$QUIET" == "TRUE" ]
then
  end_msg $SCRIPT
  exit 0
fi


#' ## Tag Replacement
#' in non-silent mode run tag replacement
#' in a loop over all tags in the template file, ask the user what value
#' should be inserted into the template
#' use process substitutions to collect the tags according to
#' https://stackoverflow.com/questions/9985076/bash-populate-an-array-in-loop
#+ tag-collect
tags=()
while read tag
do
  tags+=( ${tag} )
  # log_msg $SCRIPT "Current tag: $tag"
done < <($GETTAGSCRIPT -t $TEMPLATEPATH -u)


#' ## Notification before User Input
#' Notify user that replacement values should be entered
log_msg $SCRIPT "Enter replacement values for template tags ..."


#' In a loop over the collected tags, the user is asked for replacement values
#+ loop-user-input
for i in ${!tags[@]}
do
  # log_msg $SCRIPT "Tag loop $i: ${tags[i]}"
  CURTAG=${tags[i]}
  # check for defaults
  defaultvalue=''
  if [ "$CURTAG" == "__STARTDATE__" ]
  then
    defaultvalue=$STARTDATE
  fi
  if [ "$CURTAG" == "__AUTHORABBREV__" ]
  then
    defaultvalue=$AUTHORABBREV
  fi
  if [ "$CURTAG" == "__AUTHORNAME__" ]
  then
    defaultvalue=$AUTHORNAME
  fi
  if [ "$CURTAG" == "__BASHTOOLUTILDIR__" ]
  then
    if [ -d "$UTILDIR" ]
    then
      defaultvalue=$UTILDIR
    else
      defaultvalue=NA
    fi
  fi
  # read input from command line
  read -p "$CURTAG [$defaultvalue]: " inputvalue
  # check whether default or input should be used
  if [ -z "$inputvalue" ]
  then
    replacevalue=$defaultvalue
  else
    replacevalue=$inputvalue
  fi
  # replacement of current tag
  if [ "$VERBOSE" == "TRUE" ];then log_msg "$SCRIPT" " * Replacing $CURTAG with $replacevalue ...";fi
  # separate cases with tag followed by comment in {}
  if [ `grep "${CURTAG} {" $OUTPUTPATH | wc -l` -eq 0 ]
  then
    $SED "s#$CURTAG#$replacevalue#g" < $OUTPUTPATH  > $OUTPUTPATH.new
  else
    $SED "s#$CURTAG {.*#$replacevalue#g" < $OUTPUTPATH  > $OUTPUTPATH.new
  fi
  # prepare input of new round from output of current round
  $MV $OUTPUTPATH.new $OUTPUTPATH
done


#' ## Change Rights
#' For the script to be executable, we have to change the access rights
#+ chmod-script
log_msg "Changed rights of $OUTPUTPATH to $DEFAULTSCRIPTRIGHT"
$CHMOD $DEFAULTSCRIPTRIGHT $OUTPUTPATH


##' ## End of Script
#+ end-msg, eval=FALSE
end_msg


