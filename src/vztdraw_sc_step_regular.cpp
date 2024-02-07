#include "nhppp.h"
using namespace Rcpp;


// [[Rcpp::export]]
NumericMatrix vztdraw_sc_step_regular(
  const NumericMatrix & rate,
  const bool is_cumulative,
  const NumericMatrix & range_t,
  const bool atmost1
) {
  int n_intervals = rate.cols();
  int n_draws = rate.rows();  
  NumericMatrix Lambda(n_draws, n_intervals);
  if(!is_cumulative) {
    Lambda = matrix_cumsum_columns(rate);
  } else {
    Lambda = rate;
  }

  NumericVector interval_duration = (range_t.column(1) - range_t.column(0)) / n_intervals;

  IntegerVector n_events = rztpois_vec(Lambda(_,n_intervals-1));
  int max_events = * std::max_element(n_events.begin(), n_events.end());
  int max_cols = (atmost1) ? 1 : max_events; 

  NumericMatrix Z(n_draws, max_cols); 
  std::fill( Z.begin(), Z.end(), NumericVector::get_na() ) ;
  
  NumericMatrix Tau(n_draws, max_cols); 
  std::fill( Tau.begin(), Tau.end(), NumericVector::get_na() ) ;
  
  NumericVector tmp(max_events); 
  
  for(int r = 0; r!= n_draws; ++r) {
    for(int ev = 0; ev != n_events[r]; ++ev){
      tmp[ev] = R::runif(0, 1);
    }
    if(atmost1){
      Tau(r,0) = (*std::min_element(tmp.begin(), tmp.begin()+n_events[r])) * 
                  Lambda(r, n_intervals-1);
    } else {
      std::sort(tmp.begin(), tmp.begin()+n_events[r]);
      for(int ev = 0; ev != n_events[r]; ++ev){
        Tau(r, ev) = tmp[ev] * Lambda(r, n_intervals-1);
      }
    }
  }

  return step_regular_inverse(Z, max_events, Lambda, Tau, interval_duration, range_t, atmost1);
}


