#!/bin/bash
###
###
###
###   Purpose:   Installing bashtools
###   started:   2018-07-19 (pvr)
###
### ###################################################################### ###

# ================================ # ======================================= #
# global constants                 #                                         #
# -------------------------------- # --------------------------------------- #
# directory paths                  # used as defaults                        #
INSTALLTRG=/opt/bashtools                                                    #
# -------------------------------- # --------------------------------------- #
# prog paths                       # required for cronjob                    #  
LS=/bin/ls                         # PATH to ls                              #
ECHO=/bin/echo                     # PATH to echo                            #
SLEEP=/bin/sleep                   # path to sleep                           #
DATE=/bin/date                     # PATH to date                            #
MKDIR=/bin/mkdir                   # PATH to mkdir                           #
BASENAME=/usr/bin/basename         # PATH to basename function               #
INSTALL=/usr/bin/install           # PATH to install function                #
# ================================ # ======================================= #

#Set Script Name variable
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`


### # ====================================================================== #
### # functions
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -f <install_file> -d <install_dir> -t <install_trg>"
  $ECHO "  where <install_file> single tool to be installed"
  $ECHO "        <install_dir>  directory containing tools to be installed"
  $ECHO "        <install_trg>  target installation directory"
  exit 1
}

### # produce a start message
start_msg () {
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
}

### # produce an end message
end_msg () {
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
}

### # functions related to logging
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}

### # install single file
install_file () {
  local l_INSTALLFILE=$1
  ### # subdirectory below installation target is taken from installation file
  local l_INSTALLPATH=$INSTALLTRG/`dirname $l_INSTALLFILE`
  ### # check whether directory $l_INSTALLPATH exists, if not create it
  if [ ! -e "$l_INSTALLPATH" ]
  then
    log_msg "$SCRIPT::install_file()" "Cannot find $l_INSTALLPATH --> create it ..."
    $MKDIR -p $l_INSTALLPATH
  fi
  ### # do the installation
  log_msg "$SCRIPT::install_file()" "Installing $l_INSTALLFILE to $l_INSTALLPATH ..."
  $INSTALL $l_INSTALLFILE $l_INSTALLPATH
}

### # install all files in a directory
install_dir () {
  local l_INSTALLDIR=$1
  $LS -1 $l_INSTALLDIR/* 2> /dev/null | \
  while read e
  do
    log_msg "$SCRIPT::install_dir()" "Installing $e ..."
    install_file $e
    $SLEEP 2
  done
}


### # ====================================================================== #
### # Main part of the script starts here ...
start_msg


### # ====================================================================== #
### # Use getopts for commandline argument parsing ###
### # If an option should be followed by an argument, it should be followed by a ":".
### # Notice there is no ":" after "h". The leading ":" suppresses error messages from
### # getopts. This is required to get my unrecognized option code to work.
while getopts :f:d:t:h: FLAG; do
  case $FLAG in
    f) # set option "-f" to install a single tool  
      INSTALLFILE=$OPTARG
	    ;;
	  d) # set option "-d" to install all files in a directory
	    INSTALLDIR=$OPTARG
	    ;;
	  t) # set option "-t" to specify installation target
	    INSTALLTRG=$OPTARG
	    ;;
	  h) # option -h shows usage
	    usage "Help message for $SCRIPT"
	    ;;
	  *) # invalid command line arguments
	    usage "Invalid command line argument $OPTARG"
	    ;;
  esac
done  

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.


### # ====================================================================== #
### #  checks
### #  installation directory is specified then it has to exist
if [ ! -z "$INSTALLDIR" ]
then
  if [ ! -e "$INSTALLDIR" ]
  then
    usage "Cannot find installation directory: $INSTALLDIR"
  fi
fi
### #  installation file is specified, then it has to exist
if [ ! -z "$INSTALLFILE" ] 
then
  if [ ! -f "$INSTALLFILE" ]
  then
    usage "Cannot find installation file: $INSTALLFILE"
  fi
fi


### # ====================================================================== #
### #  preparation
if [ ! -e $INSTALLTRG ]
then
  log_msg $SCRIPT "Cannot find installation target: $INSTALLTRG --> create it ..."
  $MKDIR -p $INSTALLTRG
fi

### # depending on options that were specified, 
### # install a single file
if [  ! -z "$INSTALLFILE" ]
then
  log_msg $SCRIPT "Installing file: $INSTALLFILE"
  install_file $INSTALLFILE
fi

### # install all files in a directory
if [ ! -z "$INSTALLDIR" ]
then
  log_msg $SCRIPT "Installing all files in directory: $INSTALLDIR"
  install_dir $INSTALLDIR
fi


### # ====================================================================== #
### # Script ends here
end_msg



### # ====================================================================== #
### # What comes below is documentation that can be used with perldoc

: <<=cut
=pod

=head1 NAME

   [SCRIPT_NAME] - [SCRIPT_SHORT_TITLE]

=head1 SYNOPSIS


=head1 DESCRIPTION


=head2 Requirements



=head1 LICENSE

Artistic License 2.0 http://opensource.org/licenses/artistic-license-2.0


=head1 AUTHOR


=cut