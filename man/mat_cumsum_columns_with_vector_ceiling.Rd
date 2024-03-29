% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-vectorized.R
\name{mat_cumsum_columns_with_vector_ceiling}
\alias{mat_cumsum_columns_with_vector_ceiling}
\title{Return matrix with column-wise cumulative sum
replacing cells larger than \code{ceil} with \code{NA}.
No checks for arguments is done.}
\usage{
mat_cumsum_columns_with_vector_ceiling(X, ceil = Inf)
}
\arguments{
\item{X}{(matrix)}

\item{ceil}{(vector or Inf) the set of ceilings to be applied, per row of \code{X}}
}
\value{
matrix
}
\description{
Return matrix with column-wise cumulative sum
replacing cells larger than \code{ceil} with \code{NA}.
No checks for arguments is done.
}
