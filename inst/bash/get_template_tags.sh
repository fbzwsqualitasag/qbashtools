#!/bin/bash
###
###
###
###   Purpose:   Get all tags in a template
###   started:   2018-07-19 (pvr)
###
### ###################################################################### ###


# ======================================== # ======================================= #
# global constants                         #                                         #
# ---------------------------------------- # --------------------------------------- #
# prog paths                               # required for cronjob                    #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #
BASENAME=/usr/bin/basename                 # PATH to basename function               #
GREP=`which grep`                          # PATH to grep                            #
SORT=/usr/bin/sort                         # PATH to sort                            #
# ---------------------------------------- # --------------------------------------- #
# directories                              #                                         #
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of bashtools on host   #
UTILDIR=$INSTALLDIR                        # directory containing utilities          #
# ---------------------------------------- # --------------------------------------- #
# files                                    #                                         #
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
# ======================================== # ======================================= #


# Use utilities
UTIL=$UTILDIR/bash_utils.sh
source $UTIL

# regular expression defining the tag
REGEXTAG='__[A-Z_]*__'

### # -------------------------------------- ###
### # functions


### # -------------------------------------------- ###
### # Use getopts for commandline argument parsing ###
### # If an option should be followed by an argument, it should be followed by a ":".
### # Notice there is no ":" after "h". The leading ":" suppresses error messages from
### # getopts. This is required to get my unrecognized option code to work.
while getopts :uvt:h FLAG; do
  case $FLAG in
    u) # set option "-u" when only unique tags are wanted
      ONLYUNITAG=TRUE
      ;;
    v) # set option -v for verbose mode
      VERBOSE=TRUE
      ;;
    t) # set option "t" to get template file
      TEMPLATE=$OPTARG
	    ;;
	  h) # option -h shows usage
  	  usage $SCRIPT "Help message" "$SCRIPT -t <template_file>"
	    ;;
	  *) # invalid command line arguments
	    usage $SCRIPT "Invalid command line argument $OPTARG" "$SCRIPT -t <template_file>"
	    ;;
  esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

### # -------------------------------------------- ##
### # Main part of the script starts here ...
if [ "$VERBOSE" == "TRUE" ]
then
  start_msg $SCRIPT
fi

### # check that template file exists
if [ ! -f "$TEMPLATE" ]
then
  usage $SCRIPT "ERROR: Cannot find template_file: $TEMPLATE" "$SCRIPT -t <template_file>"
fi

### # search for template tags using grep
if [ "$ONLYUNITAG" == "TRUE" ]
then
  $GREP -o "$REGEXTAG" $TEMPLATE | $SORT -u
else
  $GREP -o "$REGEXTAG" $TEMPLATE
fi

### # -------------------------------------------- ##
### # Script ends here
if [ "$VERBOSE" == "TRUE" ]
then
  end_msg $SCRIPT
fi

### # -------------------------------------------- ##
### # What comes below is documentation that can be used with perldoc

: <<=cut
=pod

=head1 NAME

   get_template_tags - Extracting tags from a template file

=head1 SYNOPSIS

  get_template_tags.sh -t <template_file> [-u] [-v]

  where: <template_file> specifies the input template file from which tags are to be extracted


=head1 DESCRIPTION

Many files that contain scripts or programs share a common structure. This
common structure is saved in a template file. The pieces that vary between
the different instances of a collection of files is represented by tags.
These tags have a special format that does not occur in the constant
part of the template file.

The format of the template is chosen here, rather arbitrarily to match the
following regular expression

  \[[A-Z_]*\]

All this script does is a grep for the above shown regular expression on
the given templated file that is specified as input.

With option -u a sorted list of unique tags from the template file is output.
Option -v runs the script in a verbose mode with additional output.


=head2 Requirements

The template file that is specified as input must exist


=head1 LICENSE

Artistic License 2.0 http://opensource.org/licenses/artistic-license-2.0


=head1 AUTHOR

Peter von Rohr <peter.vonrohr@qualitasag.ch>

=cut
