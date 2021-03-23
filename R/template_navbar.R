## --- Template Navbar ---------------------------------------------------------
#'
#' @title Create Navbar YAML Template
#' 
#' @description 
#' For a given project containing bash scripts for which documentations were 
#' generated, a template for a yaml-definition-file for the common navbar is 
#' created. The required information is taken from the output of pkgdown::as_pkgdown.
#' 
#' @param ps_pkgdown_path path of pkgdown home 
#' @param ps_nb_yml_outfile navbar output file
#' @param pb_force_output overwrite existing output file
#' 
#' @examples 
#' \dontrun{
#' template_navbar_bash_ref(ps_pkgdown_path = '.',
#'                          ps_nb_yml_outfile = 'pkgdown/_navbar.yml')
#' }
#' 
#' @export template_navbar_bash_ref
template_navbar_bash_ref <- function(ps_pkgdown_path = '.',
                                     ps_nb_yml_outfile = '_navbar.yml',
                                     pb_force_output   = FALSE){
  pkg <- pkgdown::as_pkgdown(ps_pkgdown_path)
  # start defining a list with the navbar information
  yml_nbb_ref <- list(title = pkg$package, type = 'default')
  # add the right component
  yml_nbb_ref$right[['github']] <- list(text = 'Github', href = 'https://github.com/fbzwsqualitasag/qbashtools/')
  # add the left and right components
  yml_nbb_ref$left <- NULL  
  
  l_comp <- pkg$meta$navbar$components
  vec_cmp_names <- names(l_comp)
  for (cmp in seq_along(vec_cmp_names)){
    cur_cmp <- vec_cmp_names[cmp]
    if (is.element(cur_cmp, names(yml_nbb_ref$right)))
      next
    # add href, if it exists
    if (!is.null(l_comp[[cur_cmp]]$href)){
      # add absolute url, if needed
      s_url_prefix <- ''
      if (substr(l_comp[[cur_cmp]]$href, 1, 4) != 'http')
        s_url_prefix <- pkg$desc$get_urls()
      yml_nbb_ref$left[[cur_cmp]] <- list(text = tools::toTitleCase(cur_cmp),
                                          href = paste0(s_url_prefix, '/', l_comp[[cur_cmp]]$href, 
                                                        collapse = ''))
    }
  }

  # add the article, if it is not already in the list
  if (is.element('articles', vec_cmp_names) && !is.element('articles', names(yml_nbb_ref$left))){
    yml_nbb_ref$left[['articles']] <- list(text = 'Articles',
                                           href = paste0(pkg$desc$get_urls(), '/articles/index.html', collapse = ''))
  }
  # write list to yml file
  if (!file.exists(ps_nb_yml_outfile) || pb_force_output)
    yaml::write_yaml(yml_nbb_ref, file = ps_nb_yml_outfile)
  
  return(invisible(NULL))
}

