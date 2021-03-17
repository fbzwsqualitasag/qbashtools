#!/bin/bash
###
###
###
###   Purpose:   Utility Bash Functions
###   started:   2018-07-11 (pvr)
###
### ###################################################################### ###

# ================================ # ======================================= #
# prog paths                       # required for cronjob                    #
UT_ECHO=/bin/echo                  # PATH to echo                            #
UT_DATE=/bin/date                  # PATH to date                            #
UT_MKDIR=/bin/mkdir                # PATH to mkdir                           #
# ================================ # ======================================= #

### # usage message exit with status 1
usage () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_USAGE=$3
  $UT_ECHO " *** CALLER:  $l_CALLER"
  $UT_ECHO " *** MESSAGE: $l_MSG"
  $UT_ECHO " *** USAGE:   $l_USAGE"
  exit 1
}

### # produce a start message
start_msg () {
  local l_SCRIPT=$1
  $UT_ECHO "Starting $l_SCRIPT at: "`$UT_DATE +"%Y-%m-%d %H:%M:%S"`
}

### # produce an end message
end_msg () {
  local l_SCRIPT=$1
  $UT_ECHO "End of $l_SCRIPT at: "`$UT_DATE +"%Y-%m-%d %H:%M:%S"`
}

### # functions related to logging
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$UT_DATE +"%Y%m%d%H%M%S"`
  $UT_ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}

### # check whether the file exists independent of its type
check_exist_fail () {
  local l_check_file=$1
  if [ ! -e $l_check_file ]
  then
    log_msg check_exist_fail "FAILED because CANNOT find file: $l_check_file"
    exit 1
  fi
}

### # check whether file exists, if not fail
check_exist_file_fail () {
  local l_check_file=$1
  if [ ! -f $l_check_file ]
  then
    log_msg check_exist_file_fail "FAILED because CANNOT find file: $l_check_file"
    exit 1
  fi
}

### # check whether a directory exits, if not fail
check_exist_dir_fail () {
  local l_check_dir=$1
  if [ ! -d "$l_check_dir" ]
  then
    log_msg check_exist_dir_fail "FAILED because CANNOT find directory: $l_check_dir"
    exit 1
  fi
}

#' ### Create Dir
#' Specified directory is created, if it does not yet exist
#+ check-exist-dir-create-fun
check_exist_dir_create () {
  local l_check_dir=$1
  if [ ! -d "$l_check_dir" ]
  then
    log_msg check_exist_dir_create "CANNOT find directory: $l_check_dir ==> create it"
    $UT_MKDIR -p $l_check_dir
  fi

}

### # check whether directory already exists, if yes then fail
check_already_exists_dir_fail () {
  local l_check_dir=$1
  if [ -d "$l_check_dir" ]
  then
    log_msg check_already_exists_dir_fail "FAILED because directory: $l_check_dir already exists"
    exit 1
  fi
}

### # check whether file already exists, if yes then fail
check_already_exists_file_fail () {
  local l_check_file=$1
  if [ -f "$l_check_file" ]
  then
    log_msg check_already_exists_file_fail "FAILED because file: $l_check_file already exists"
    exit 1
  fi
}
