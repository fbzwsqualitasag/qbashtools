## --- Build Reference Page For Bash Scripts ----------------------------------
#'
#' @title Build Reference Page For Bash Script Documentations
#' 
#' @description 
#' Bash scripts given in a vector to ps_script_path are converted into 
#' html-pages. These pages are moved to an output directory. An index 
#' page is constructed which can be referred by other pages.
#' 
#'
#' @param ps_script_path path to scripts
#' @param ps_out_dir directory for output files
#' @param ps_navbar_path, path to a navbar yml file
#' @param pb_force_output force to create output
#' @param pb_keep_rmd keep generated Rmd files
#'
#' @examples 
#' \dontrun{
#' build_bash_ref(ps_script_path = file.path('inst', 'bash'), 
#'                ps_out_dir     = file.path('docs', 'bash_ref'),
#'                ps_navbar_path = file.path('pkgdown', '_navbar.yml') )
#' }
#' 
#' @export build_bash_ref   
build_bash_ref <- function(ps_script_path, 
                           ps_out_dir,
                           ps_navbar_path  = NULL,
                           pb_force_output = FALSE,
                           pb_keep_rmd     = FALSE){
  
  # if ps_script_path is a directory, take all bash scripts in that directory as input
  if (fs::dir_exists(ps_script_path)){
    vec_script_path <- list.files(path = ps_script_path, pattern = '.sh$', full.names = TRUE)
  } else {
    vec_script_path <- ps_script_path
  }
  # if ps_out_dir does not exist, create it
  if (!fs::dir_exists(ps_out_dir)) fs::dir_create(path = ps_out_dir)
  # convert bash scripts to html pages
  for (s in vec_script_path){
    # convert current script s to html
    spin_sh(ps_sh_hair = s)
    # move generated html file to ps_out_dir
    cur_out_path <- paste(fs::path_ext_remove(basename(s)), '.html', sep = '')
    # if output was generated, move it
    if (fs::file_exists(cur_out_path))
      fs::file_move(path = cur_out_path, new_path = ps_out_dir)
  }
  # create an index page
  create_index_page(ps_out_dir      = ps_out_dir, 
                    ps_navbar_path  = ps_navbar_path, 
                    pb_force_output = pb_force_output,
                    pb_keep_rmd     = pb_keep_rmd)
}

## --- Create Index Page ------------------------------------------------------
#'
#' @title Create Index Page for Bash Scripts
#' 
#' @description 
#' For a given directory containing html-documentations of bash scripts, 
#' an index page is constructed. The html-pages are read and titles are extracted. 
#' The titles and the links to the html pages are collected into a table which 
#' is written to an output file in Rmarkdown format. This is rendered to an 
#' html-page.
#' 
#' @param ps_out_dir directory with html-files for which index is to be created
#' @param ps_out_file name of index output file
#' @param ps_navbar_path, path to a navbar yml file
#' @param pb_force_output force to create output
#' @param pb_keep_rmd keep Rmd source file
#'
#' @examples 
#' \dontrun{
#' create_index_page(ps_out_dir = 'docs/bash_ref')
#' }
#' 
create_index_page <- function(ps_out_dir, 
                              ps_out_file     = 'index.html', 
                              ps_navbar_path  = NULL,
                              pb_force_output = FALSE,
                              pb_keep_rmd     = FALSE){
  # vector with html files
  vec_html_path <- list.files(path = ps_out_dir, pattern = '.html$', full.names = TRUE)
  # result tibble
  tbl_index_table <- NULL
  # loop over html files
  for (h in vec_html_path){
    s_cur_title <- get_title(ps_html_path = h)
    s_cur_html_file <- basename(h)
    s_cur_script_stem <- fs::path_ext_remove(s_cur_html_file)
    cur_table_row <- tibble::tibble(Script  = paste0('[', s_cur_script_stem, '](', s_cur_html_file, ')', collapse = ''),
                                    Title = s_cur_title)
    # append
    if (is.null(tbl_index_table)){
      tbl_index_table <- cur_table_row
    } else {
      tbl_index_table <- dplyr::bind_rows(tbl_index_table, cur_table_row)
    }
  }
  # write the index table, start with yaml header
  s_html_path <- file.path(ps_out_dir, ps_out_file)
  s_rmd_path <- file.path(ps_out_dir, paste(fs::path_ext_remove(ps_out_file), '.Rmd', sep = ''))
  cat("---\noutput: html_document\n---\n\n", file = s_rmd_path)
  # Title
  cat("## Bash Scripts\n\nIndex page for bash scripts.\n\n", file = s_rmd_path, append = TRUE)
  # Table
  s_index_table <- knitr::kable(tbl_index_table)
  cat(s_index_table, sep = '\n', file = s_rmd_path, append = TRUE)
  # copy navbar, if it exists
  if (file.exists(ps_navbar_path)){
    s_new_nb_path <- file.path(ps_out_dir, basename(ps_navbar_path))
    if (pb_force_output) fs::file_delete(s_new_nb_path)
    fs::file_copy(path = ps_navbar_path, new_path = s_new_nb_path)
  } else {
    cat(" *** CANNOT FIND navbar: ", ps_navbar_path, "\n")
  }
    
  # render
  rmarkdown::render(input = s_rmd_path, output_file = s_html_path)
  # clean up rmd file
  if (!pb_keep_rmd)
    fs::file_delete(path = s_rmd_path)
  return(invisible(TRUE))
}

## --- Get Title from an HTML File --------------------------------------------
#'
#' @title Get Title From HTML File
#' 
#' @description 
#' The html page generated from a script contains a title between html-tags. 
#' This function searches for the title-tag and returns the string that is 
#' between the tags.
#' 
#' @param ps_html_path 
#' @return s_cur_title Title from html page
#' 
#' @examples 
#' \dontrun{
#' get_title(ps_html_path = 'docs/bash_ref/new_bash_script.html')
#' }
#' 
get_title <- function(ps_html_path) {
  # read the html file to get to the title
  vec_cur_page <- readLines(con = ps_html_path)
  # title is in html tags
  s_cur_title <- grep(pattern = '<title>', vec_cur_page, fixed = TRUE, value = TRUE)
  # remove the tags
  s_cur_title <- gsub('</?title>', '', s_cur_title)
  return(s_cur_title)
}




