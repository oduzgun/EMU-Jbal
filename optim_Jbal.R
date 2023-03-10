#' This code uses the L-BFGS-B optimization algorithm to implement entropy balancing (currently the one proposed by Hainmueller (2012)).
#'
#' The function takes the following input arguments:
#' @params tr.total: A vector of target values.
#' @params co.x: A matrix of values used to compute the weights in the optimization procedure.
#' @params base.weight: A scalar value used to compute the weights.
#' @params control: A list of control parameters for the L-BFGS-B optimizer, such as the maximum number of iterations or tolerance for convergence.
#'
#' @return It returns optimized coefficients, final weights, and the loss.
#' 
#' @author Onur Düzgün

optim_Jbal <- function(tr.total, co.x, base.weight, control=list()) {
  
  # Adding some checks
  if (!is.vector(tr.total)) {
    stop("tr.total must be a vector")
  }
  if (length(tr.total) != nrow(co.x)) {
    stop("tr.total must have the same number of elements as there are rows in co.x")
  }
  if (!is.matrix(co.x)) {
    stop("co.x must be a matrix")
  }
  if (nrow(co.x) != length(tr.total)) {
    stop("co.x must have the same number of rows as there are elements in tr.total")
  }
  if (!is.vector(base.weight)) {
    stop("base.weight must be a vector")
  }
  if (length(base.weight) != length(tr.total)) {
    stop("base.weight must have the same length as tr.total")
  }
  if (!is.list(control)) {
    stop("control must be a list")
  }
  if (!("constraint.tolerance" %in% names(control))) {
    stop("control must contain a key named constraint.tolerance")
  }
  
  # Pre-allocating memory for the coefficients
  lambda <- rep(0, ncol(co.x))
  
  # Defining the function to be minimized
  loss_fun <- function(lambda) {
    # Computing weights
    weights <- exp(co.x %*% lambda) * base.weight
    # Aggregating values in co.x
    co.x.agg <- t(weights) %*% co.x
    # Computing deviations from target values
    deviation <- co.x.agg - tr.total
    # Returning sum of squared deviations as the loss function 
    # (UPCOMING: User may specify other options such as RMSE, MAE or correlation coefficient)
    return(sum(deviation^2))
  }
  
  # Using try-catch to handle any errors that may occur during optimization
  tryCatch({
    # Using L-BFGS-B to minimize the loss function
    result <- optim(par=lambda, fn=loss_fun, tr.total=tr.total, co.x=co.x, base.weight=base.weight,
                    method="L-BFGS-B", control=list(maxit=1000, reltol=1e-6))
  }, error=function(e) {
    stop(paste("Error during optimization:", e))
  })
  
  # Checking that the optimization function returned successfully
  if (is.null(result)) {
    stop("Optimization failed")
  }
  
  # Computing the final weights
  weights <- exp(co.x %*% result$par) * base.weight
  if (abs(sum(weights) - 1) > 1e-6) {
    stop("Final weights must sum to 1")
  }
  
  # Extracting optimized coefficients, final weights, and the loss
  lambda <- result$lambda
  weights <- result$weights
  loss <- result$loss
  
  # Just a quick check if the optimization converged within the tolerance
  converged <- max(abs(co.x.agg - tr.total)) < control$constraint.tolerance
  if(converged){cat("Converged within tolerance \n")}
  
  return(list(maxdiff=max(abs(co.x.agg - tr.total)), coefs=lambda, weights.ebal=weights, converged=converged))
}
