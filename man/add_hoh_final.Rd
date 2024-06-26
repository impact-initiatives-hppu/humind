% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_hoh_final.R
\name{add_hoh_final}
\alias{add_hoh_final}
\title{Head of household final values (from respondent skip logic)}
\usage{
add_hoh_final(
  df,
  resp_hoh_yn = "resp_hoh_yn",
  yes = "yes",
  no = "no",
  hoh_gender = "hoh_gender",
  hoh_age = "hoh_age",
  resp_gender = "resp_gender",
  resp_age = "resp_age"
)
}
\arguments{
\item{df}{The input dataframe.}

\item{resp_hoh_yn}{The column name for whether the respondent is the head of household (hoh) yes/no indicator.}

\item{yes}{The value for 'yes' in the 'resp_hoh_yn' column.}

\item{no}{The value for 'no' in the 'resp_hoh_yn' column.}

\item{hoh_gender}{The column name for the household (hoh) gender.}

\item{hoh_age}{The column name for the household (hoh) age.}

\item{resp_gender}{The column name for the respondent (resp) gender.}

\item{resp_age}{The column name for the respondent (resp) age.}
}
\value{
The modified dataframe with updated hoh_gender and hoh_age columns.
}
\description{
Head of household final values (from respondent skip logic)
}
