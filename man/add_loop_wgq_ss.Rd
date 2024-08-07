% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_loop_wgq_ss.R
\name{add_loop_wgq_ss}
\alias{add_loop_wgq_ss}
\alias{add_loop_wgq_ss_to_main}
\title{Prepare dummy variables for each WG-SS component (individual data)}
\usage{
add_loop_wgq_ss(
  loop,
  ind_age = "ind_age",
  vision = "wgq_vision",
  hearing = "wgq_hearing",
  mobility = "wgq_mobility",
  cognition = "wgq_cognition",
  self_care = "wgq_self_care",
  communication = "wgq_communication",
  no_difficulty = "no_difficulty",
  some_difficulty = "some_difficulty",
  lot_of_difficulty = "lot_of_difficulty",
  cannot_do = "cannot_do",
  undefined = c("dnk", "pnta")
)

add_loop_wgq_ss_to_main(
  main,
  loop,
  wgq_dis_4 = "wgq_dis_4",
  wgq_dis_3 = "wgq_dis_3",
  wgq_dis_2 = "wgq_dis_2",
  wgq_dis_1 = "wgq_dis_1",
  ind_age_above_5 = "ind_age_above_5",
  id_col_main = "uuid",
  id_col_loop = "uuid"
)
}
\arguments{
\item{loop}{A data frame of individual-level data.}

\item{ind_age}{The individual age column.}

\item{vision}{Vision component column.}

\item{hearing}{Hearing component column.}

\item{mobility}{Mobility component column.}

\item{cognition}{Cognition component column.}

\item{self_care}{Self-care component column.}

\item{communication}{Communication component column.}

\item{no_difficulty}{Level for no difficulty.}

\item{some_difficulty}{Level for some difficulty.}

\item{lot_of_difficulty}{Level for a lot of difficulty.}

\item{cannot_do}{Level for cannot do at all.}

\item{undefined}{Vector of undefined responses, such as Prefer not to answer and Don't know.}

\item{main}{A data frame of household-level data.}

\item{wgq_dis_4}{Column name for the disability 4 cut-offs binary.}

\item{wgq_dis_3}{Column name for the disability 3 cut-offs binary.}

\item{wgq_dis_2}{Column name for the disability 2 cut-offs binary.}

\item{wgq_dis_1}{Column name for the disability 1 cut-offs binary.}

\item{ind_age_above_5}{Column name for the age above 5 dummy in the individual-level dataset.}

\item{id_col_main}{Column name for the unique identifier in the main dataset.}

\item{id_col_loop}{Column name for the unique identifier in the loop dataset.}
}
\description{
\link{add_loop_wgq_ss} prepares dummy variables for each WG-SS component (vision, hearing, mobility, cognition, self-care, communication) and their levels (no difficulty, some difficulty, a lot of difficulty, cannot do at all) and combines them into the sum of domains coded for each level (e.g, wgq_cannot_do_n), and disability binary cut-offs variables (wgq_dis_1, wgq_dis_2, wgq_dis_3, wgq_dis_4).
}
