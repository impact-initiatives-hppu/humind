% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_loop_edu_disrupted_d.R
\name{add_loop_edu_disrupted_d}
\alias{add_loop_edu_disrupted_d}
\alias{add_loop_edu_disrupted_d_to_main}
\title{Add Education Disruption Categories}
\usage{
add_loop_edu_disrupted_d(
  df,
  attack = "edu_disrupted_attack",
  hazards = "edu_disrupted_hazards",
  displaced = "edu_disrupted_displaced",
  teacher = "edu_disrupted_teacher",
  levels = c("yes", "no", "dnk", "pnta"),
  ind_schooling_age_d = "edu_ind_schooling_age_d"
)

add_loop_edu_disrupted_d_to_main(
  main,
  loop,
  attack_d = "edu_disrupted_attack_d",
  hazards_d = "edu_disrupted_hazards_d",
  displaced_d = "edu_disrupted_displaced_d",
  teacher_d = "edu_disrupted_teacher_d",
  id_col_main = "uuid",
  id_col_loop = "uuid"
)
}
\arguments{
\item{df}{A data frame containing individual-level education data.}

\item{attack}{Column name for attack disruption. NULL if dimension is not present in the data frame.}

\item{hazards}{Column name for hazards disruption.}

\item{displaced}{Column name for displaced disruption.}

\item{teacher}{Column name for teacher disruption.}

\item{levels}{Vector of levels for the disruption variables.}

\item{ind_schooling_age_d}{Column name for the dummy variable of the schooling age class.}

\item{main}{A data frame of household-level data.}

\item{loop}{A data frame of individual-level data.}

\item{attack_d}{Column name for the dummy variable of the attack dimension. NULL if dimension is not present in the data frame.}

\item{hazards_d}{Column name for the dummy variable of the hazards dimension.}

\item{displaced_d}{Column name for the dummy variable of the displaced dimension.}

\item{teacher_d}{Column name for the dummy variable of the teacher dimension.}

\item{id_col_main}{Column name for the unique identifier in the main dataset.}

\item{id_col_loop}{Column name for the unique identifier in the loop dataset.}
}
\value{
A data frame with additional columns:
\itemize{
\item *_d: Binary columns for each disruption type (e.g., edu_disrupted_attack_d).
}

A data frame with additional columns:
\itemize{
\item edu_disrupted_*_n: Count of individuals experiencing each type of education disruption (e.g., edu_disrupted_hazards_n).
}
}
\description{
This function adds education disruption binaries to individual-level data and summarizes them at the household level. It includes two main functions: \code{\link[=add_loop_edu_disrupted_d]{add_loop_edu_disrupted_d()}} for individual-level data and \code{\link[=add_loop_edu_disrupted_d_to_main]{add_loop_edu_disrupted_d_to_main()}} for household-level data.

Prerequisite function:
\itemize{
\item add_loop_edu_ind_age_corrected.R
}
}
