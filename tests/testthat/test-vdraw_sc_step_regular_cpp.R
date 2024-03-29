test_that("vdraw_sc_step_regular_cpp() works", {
  # 1 row matrix
  expect_no_error(Z0 <- vdraw_sc_step_regular_cpp(
    Lambda_matrix = matrix(1:5, nrow = 1),
    range_t = c(100, 110),
    tol = 10^-6,
    atmost1 = FALSE
  ))
  check_ppp_sample_validity(Z0, t_min = 100, t_max = 110)


  l <- lref <- matrix(rep(1, 50), ncol = 5)
  L <- Lref <- mat_cumsum_columns(l)

  expect_no_error(Z <- vdraw_sc_step_regular_cpp(
    Lambda_matrix = L,
    range_t = c(100, 110),
    tol = 10^-6,
    atmost1 = FALSE
  ))
  check_ppp_sample_validity(Z, t_min = 100, t_max = 110)

  expect_no_error(Z1 <- vdraw_sc_step_regular_cpp(
    Lambda_matrix = L,
    range_t = c(100, 110),
    tol = 10^-6,
    atmost1 = TRUE
  ))
  check_ppp_sample_validity(Z1, t_min = 100, t_max = 110)

  expect_no_error(Z2 <- vdraw_sc_step_regular_cpp(
    lambda_matrix = l,
    range_t = c(100, 110),
    tol = 10^-6,
    atmost1 = TRUE
  ))
  check_ppp_sample_validity(Z2, t_min = 100, t_max = 110)

  expect_equal(L, Lref) # no side effects on l, L
  expect_equal(l, lref)
})

test_that("vdraw_sc_step_regular_cpp() does not break with matrices whose mode is list", {
  l <- matrix(rep(1, 50), ncol = 5)
  L <- mat_cumsum_columns(l)

  mode(L) <- "list"
  expect_no_error(Z <- vdraw_sc_step_regular_cpp(
    Lambda_matrix = L,
    range_t = c(100, 110),
    tol = 10^-6,
    atmost1 = FALSE
  ))
})

test_that("vdraw_sc_step_regular_cpp() works with subinterval", {
  expect_no_error(Z0 <- vdraw_sc_step_regular_cpp(
    Lambda_matrix = matrix(1:5, nrow = 1),
    range_t = c(100, 110),
    subinterval = c(100, 110),
    tol = 10^-6,
    atmost1 = FALSE
  ))
  check_ppp_sample_validity(Z0, t_min = 100, t_max = 110, atmost1 = FALSE)
  expect_no_error(Z0 <- vdraw_sc_step_regular_cpp(
    Lambda_matrix = matrix(1:5, nrow = 1),
    range_t = c(100, 110),
    subinterval = c(101.01, 108.99),
    tol = 10^-6,
    atmost1 = FALSE
  ))
  check_ppp_sample_validity(Z0, t_min = 101.01, t_max = 108.99, atmost1 = FALSE)

  expect_no_error(Z0 <- vdraw_sc_step_regular_cpp(
    Lambda_matrix = matrix(1:5, nrow = 1) * 10,
    range_t = c(100, 110),
    subinterval = c(105.01, 105.99),
    tol = 10^-6,
    atmost1 = FALSE
  ))
  check_ppp_sample_validity(Z0, t_min = 105.01, t_max = 105.99, atmost1 = FALSE)
})
