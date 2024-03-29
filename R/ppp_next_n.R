#' Simulate n events from a homogeneous Poisson Point Process.
#'
#' @param rate scalar instantaneous rate
#' @param n scalar number of samples
#' @param t_min scalar for the starting time value
#' @param rng_stream an `rstream` object
#'
#' @return a vector with event times t (starting from t_min)
#' @export
#'
#' @examples
#' x <- ppp_next_n(n = 10, rate = 1, t_min = 0)
#' @importClassesFrom rstream rstream.mrg32k3a
ppp_next_n <- function(n = 1, rate = 1, t_min = 0, rng_stream = NULL) {
  dt_ <- rng_stream_rexp(size = n, rate = rate, rng_stream = rng_stream)
  t_ <- cumsum(dt_) + t_min
  return(t_)
}
