#' Display the summary statistics of covariates before and after matching.
#'
#' This function takes three arguments:
#' @param matchbal_output: A list containing data about the results of the MatchBalance() function before and after matching.
#' @param variable_names: A character vector of variable names being analyzed.
#' @param after_matching: A logical value indicating whether to use data from before or after matching. 
#'
#' The function returns a matrix with balance statistics for the specified variables.
#' @return A matrix containing the mean treatment, mean control, standard deviation difference, standard deviation difference pooled, 
#' variance ratio, T p-value, KS p-value, mean difference, median difference, and maximum difference for each variable.
#'
#' @author Onur Düzgün


cov.balcheck <- function(MatchBalance_output, variable_names, after_matching = TRUE) {
  
  # Adding some checks
  if (!is.list(MatchBalance_output) || length(MatchBalance_output) != 2) {
    stop("Error: matchbal_output must be a list with two elements.")
  }
  if (!is.character(variable_names) || length(variable_names) != nrow(output_matrix)) {
    stop("Error: variable_names must be a character vector with the same number of elements as the number of rows in output_matrix.")
  }
  if (!is.logical(after_matching)) {
    stop("Error: after_matching must be a logical value.")
  }
  
  # Selecting the columns needed in the output matrix
  tryCatch({
    output_matrix <- ifelse(after_matching == FALSE, 
                           select(MatchBalance_output$BeforeMatching, mean.Tr, mean.Co, sdiff, sdiff.pooled, 
                           var.ratio, p.value, ks.boot.pvalue = ks$ks.boot.pvalue, meandiff = qqsummary$meandiff, 
                           mediandiff = qqsummary$mediandiff, maxdiff = qqsummary$maxdiff),
                           select(MatchBalance_output$AfterMatching, mean.Tr, mean.Co, sdiff, sdiff.pooled, 
                           var.ratio, p.value, ks.boot.pvalue = ks$ks.boot.pvalue, meandiff = qqsummary$meandiff, 
                           mediandiff = qqsummary$mediandiff, maxdiff = qqsummary$maxdiff))
  }, error = function(e) {
    stop("Error: An error occurred while attempting to select columns from MatchBalance() output:", e)
  })
  
  # Checking that the necessary columns exist in MatchBalance_output$BeforeMatching or MatchBalance_output$AfterMatching
  if (!all(c("mean.Tr", "mean.Co", "sdiff", "sdiff.pooled", "var.ratio", "p.value") %in% colnames(output_matrix)) || 
      !all(c("ks.boot.pvalue", "meandiff", "mediandiff", "maxdiff") %in% names(ks)) || 
      !all(c("meandiff", "mediandiff", "maxdiff") %in% names(qqsummary))) {
    stop("Error: The necessary columns or elements do not exist in MatchBalance_output or ks/qqsummary.")
  }
  
  # Setting the column and row names
  colnames(output_matrix) <- c("mean_treatment", "mean_control", "sdiff", "sdiff_pooled", 
                               "var_ratio", "T_pval", "KS_pval", "qqmeandiff", "qqmediandiff", "qqmaxdiff")
  rownames(output_matrix) <- variable_names
  
  return(output_matrix)
}
