library(tidyverse)
library(tictoc)

dat <- readRDS("refactor/SEER_WM_50K_data.rds")
lambda_death <- readRDS("refactor/dt_intensities_death_from_other_causes.rds")


#### Piecewise constant function for death from other causes
L <- lambda_death |>
  dplyr::filter(sex == "male" & race == "white" & cohort == 1940 & intensity == "Lambda") |>
  dplyr::filter(age >=40 & age <= 77) |>
  dplyr::select(age, estimate) |>
  tidyr::pivot_wider( names_from = age, values_from = estimate) |>
  as.matrix()
n_people <- 10000
L_mat <- L[rep(1, n_people),]


death_other_causes <- nhppp::vztdraw_sc_step_regular_cpp(Lambda_matrix = L_mat,
                                                     range_t = c(40, 110),
                                                     atmost1 = TRUE)




####  Lesion intensity function and its arguments
lesion_intensity_function <- function(age, lambda_args = list(trunc_age = 80, jump_age = 60)) {
   exp(-10 + 0.08 * age * as.numeric(age < lambda_args$trunc_age) +
         0.08 * lambda_args$trunc_age * as.numeric(age >= lambda_args$trunc_age) +
         0.5 * as.numeric(age >= lambda_args$jump_age))
}

#plot(x = c(40:100), y = lesion_intensity_function(age = c(40:100)))


#### Majorizer for the lesion intensity function
n_lambda_intervals <- 20
l_maj_mat <- matrix(NA, ncol = n_lambda_intervals, nrow = n_people)
for(r in 1:n_people) {
  t_steps <- seq(40, death_other_causes[r,1], length.out = n_lambda_intervals+1)
  l_maj_mat[r,] <- pmax(lesion_intensity_function(t_steps[1:n_lambda_intervals]),
                      lesion_intensity_function(t_steps[2:(n_lambda_intervals+1)]))
}
tictoc::tic()
lesion_times <- vdraw_intensity_step_regular_cpp(
    lambda = lesion_intensity_function,
    lambda_args = list(trunc_age = 80, jump_age = 60),
    lambda_maj_matrix = l_maj_mat,
    range_t = cbind(rep(40, n_people), death_other_causes)
  )
tictoc::toc()

#### Sampling conditional of ≥1 lesion

for(i in 1:5) {
  tictoc::tic()
  death_other_causes <- nhppp::vztdraw_sc_step_regular_cpp(Lambda_matrix = L_mat,
                                                           range_t = c(40, 110),
                                                           atmost1 = TRUE)

  lesion_times <- vztdraw_intensity_step_regular_R(
    lambda = lesion_intensity_function,
    lambda_args = list(trunc_age = 80, jump_age = 60),
    lambda_maj_matrix = l_maj_mat,
    range_t = cbind(rep(40, n_people), death_other_causes)
  )
  tictoc::toc()
}




#################################################################
# Transition parameters
#################################################################

edges_dt <- data.table::data.table(
  edge_start = c("PUNLMP [VLIP]", "Ta-LG [HIP LG]",
                       "T1-LG [HIP LG]", "T1-LG [HIP LG]",
                       "Ta-HG [HIP HG]", "T1-HG [HIP HG]",
                       "T1-HG [HIP HG]", "Tis [CIS]",
                       "Tis [CIS]", "T1-HG [CIS]",
                       "T1-HG [CIS]",  "T1-HG [NUC]",
                       "T1-HG [NUC]", "Locally advanced disease",
                       "Locally advanced disease", "Metastasis"
     ),
  edge_end = c("Ta-LG [HIP LG]", "T1-LG [HIP LG]",
                    "Locally advanced disease", "BC death",
                    "T1-HG [HIP HG]", "Locally advanced disease",
                    "BC death", "T1-HG [CIS]",
                    "Locally advanced disease", "Locally advanced disease",
                    "BC death",  "Locally advanced disease",
                    "BC death", "Metastasis",
                    "BC death", "BC death"
                    ),
  edge_log_N = c(
    0.02297436, 0.02297436, 0.01430167, 10^-10,
    0.02297436, 0.05720668, 0.02261079, 0.02261079,
    0.5720668, 0.5720668, 0.02261079, 0.05720668,
    0.022610791, 0.479733, 0.3818439, 0.6868871
  )
)

node_dt <- data.table::data.table(
  starting_states = c("Papilloma [VLIP]", "PUNLMP [VLIP]", "Ta-LG [HIP LG]",
                     "T1-LG [HIP LG]", "Ta-HG [HIP HG]", "T1-HG [HIP HG]",
                     "Tis [CIS]", "T1-HG [CIS]", "T1-HG [NUC]",
                     "Locally advanced disease", "Metastasis", "BC death"
                     ),
  starting_state_prob = c(0.00, 0.00, 0.675,
                          0.00, 0.225, 0.00,
                          0.09, 0.00, 0.01,
                          0.00, 0.00, 0.00
                          )
)



verhulst_equation <- function(lesion_age, flat_morphology, N_0 = 1e+06, N_inf = 1.8e+11, growth_rate = 0.6674412, N_inf_CIS = 4.57e+08, N_inf_nonCIS = 1.8e+11) {
  N_0 * exp(growth_rate * lesion_age) /
    (1 + (N_0 / (N_inf_CIS + (N_inf_nonCIS - N_inf_CIS) * flat_morphology) ) *
       (exp(growth_rate * lesion_age) - 1))
}

evaluate_transition_intensity <- function(lesion_age, lambda_args=list(flat_morphology = FALSE, edge_log_N = 0)) {
  N <- verhulst_equation(lesion_age = lesion_age, flat_morphology = lambda_args$flat_morphology)
  lambda_args$edge_log_N * log(N)
}

# Lesion data table
lesion_dt <- data.table::as.data.table(
  list(
    id = 1:nrow(lesion_times),
    spawn_age = 40,
    death_other_causes = death_other_causes,
    lesion_inception = lesion_times[, 1, drop = FALSE],
    lesion_starting_state = sample(x = node_dt[, starting_states],
                                   prob = node_dt[, starting_state_prob],
                                   replace = TRUE,
                                   size = nrow(lesion_times)
                                   )
  )
)
lesion_dt[, "flat_morphology"] <- ifelse(lesion_dt[, lesion_starting_state == "Tis [CIS]"], 1, 0)
lesion_dt[, "lesion_stop_age"] <- death_other_causes - lesion_dt[, "lesion_inception"]
lesion_dt_long <- dplyr::left_join(lesion_dt, edges_dt,
                        by = c("lesion_starting_state" = "edge_start"),
                        relationship = "many-to-many")
data.table::setkey(lesion_dt_long, "id")


# # Majorizer -- slow
# tictoc::tic()
# n_lambda_intervals <- 20
# transition_maj_mat <- matrix(NA, ncol = n_lambda_intervals, nrow = nrow(lesion_dt_long))
# for(r in 1:nrow(lesion_dt_long)) {
#   t_steps <- seq(0, lesion_dt_long[r, lesion_stop_age], length.out = n_lambda_intervals + 1)
#   flat_morphology <- lesion_dt_long[r, flat_morphology]
#   edge_log_N <- lesion_dt_long[r, edge_log_N]
#
#   transition_maj_mat[r,] <- pmax(
#     evaluate_transition_intensity(t_steps[1:n_lambda_intervals]),
#     evaluate_transition_intensity(t_steps[2:(n_lambda_intervals+1)]))
# }
# tictoc::toc()

# Majorizer -- ~200 times faster
tictoc::tic()
lambda_args <- list(flat_morphology = lesion_dt_long[, flat_morphology],
                    edge_log_N = lesion_dt_long[, edge_log_N])
n_lambda_intervals <- 5
range_t = as.matrix(lesion_dt_long[, .(0, lesion_stop_age)])
n_rows <- nrow(lesion_dt_long)
t_steps <- matrix(
  rep(range_t[,1], n_lambda_intervals + 1) +
  rep(seq.int(from = 0, to = 1, length.out = n_lambda_intervals + 1), each = n_rows) *
  rep(range_t[,2] - range_t[,1], n_lambda_intervals + 1),
  ncol = n_lambda_intervals + 1)

L <- evaluate_transition_intensity(t_steps[,], lambda_args = lambda_args)
L <- pmax(as.vector(L[,1:n_lambda_intervals]), as.vector(L[,2:(n_lambda_intervals+1)]))
transition_maj_mat <- matrix(L, ncol = n_lambda_intervals)
tictoc::toc()


tmp <- vdraw_sc_step_regular(
  lambda_matrix = transition_maj_mat,
  range_t = as.matrix(lesion_dt_long[, .(0, lesion_stop_age)]),
  atmost1 = TRUE
)

tictoc::tic()
lesion_transition_age <- vdraw_intensity_step_regular_cpp(
  lambda = evaluate_transition_intensity,
  lambda_args = list(flat_morphology = lesion_dt_long[, flat_morphology],
                     edge_log_N = lesion_dt_long[, edge_log_N]
                     ),
  lambda_maj_matrix = transition_maj_mat,
  range_t = as.matrix(lesion_dt_long[, .(0, lesion_stop_age)]),
  atmost1 = TRUE
)
tictoc::toc()





