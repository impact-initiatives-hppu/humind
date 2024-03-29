% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/time_to_fetch_water_int_to_char.R
\name{time_to_fetch_water_int_to_char}
\alias{time_to_fetch_water_int_to_char}
\alias{time_to_fetch_water_combine}
\title{Shape the time to fetch water to recoding state}
\usage{
time_to_fetch_water_int_to_char(
  df,
  var,
  int = c(0, 30, 60, 600),
  char = c("premises", "30_min_or_less", "more_than_30_to_1hr", "more_than_1hr"),
  int_dontknow = c(-999, 999),
  char_dontknow = "dnk",
  sl_piped_into_dwelling = TRUE,
  var_piped_into_dwelling = "drinking_water_source",
  codes_piped_into_dwelling = c("piped_into_dwelling")
)

time_to_fetch_water_combine(
  df,
  var_int_to_char = "time_to_fetch_water_int_to_char",
  var_dontknow = "time_to_fetch_water_dontknow",
  level_codes = c("premises, 30_min_or_less, more_than_30_to_1hr, more_than_1hr, dnk")
)
}
\arguments{
\item{df}{A data frame.}

\item{var}{The name of the integer variable to be recoded.}

\item{int}{A vector of integer thresholds to define the thresholds.}

\item{char}{A vector of labels for each category. The labels correspond to the categories defined by the thresholds. The first label corresponds to values less than or equal to the first threshold, the second label corresponds to values greater than the first threshold and less than or equal to the second threshold, and so on.}

\item{int_dontknow}{A vector of integer values to be treated as "don't know" and replaced with \code{char_dontknow}.}

\item{char_dontknow}{A character value to be used as the label for "don't know" values.}

\item{sl_piped_into_dwelling}{A logical value indicating whether a skip logic was implemented using variable \code{var_piped_into_dwelling}. If \code{TRUE}, the function will recode the variable \code{var_piped_into_dwelling} to premises whenever it is \code{codes_piped_into_dwelling} before recoding \code{var}.}

\item{var_piped_into_dwelling}{The name of the variable to be recoded to premises.}

\item{codes_piped_into_dwelling}{A vector of codes to be recoded to premises.}

\item{var_int_to_char}{The recoded integer variable.}

\item{var_dontknow}{The character variable when do not know.}

\item{level_codes}{The character level codes.}
}
\value{
The input data frame with the recoded variable added as a new column.
}
\description{
\code{time_to_fetch_water_int_to_char()} recodes the time to fetch water to categorical thresholds (incl. ) and \code{time_to_fetch_water_combine()} combines both the recoded integer variable and the character variable into one final character time to fetch water. See 2023 MSNA indicator bank for further information.
}
