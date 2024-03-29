% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fclcp.R
\name{fclcp}
\alias{fclcp}
\title{FEWS NET Food Consumption-Livelihood Coping Phase}
\usage{
fclcp(
  df,
  fcp = "fcp",
  lcsi_cat_no_exhaustion = "lcsi_cat_no_exhaustion",
  lcsi_levels = c("None", "Stress", "Crisis", "Emergency")
)
}
\arguments{
\item{df}{A data frame.}

\item{fcp}{The food consumption phase column.}

\item{lcsi_cat_no_exhaustion}{The Livelihood Coping Strategies categories column without the exhaustion of strategies.}

\item{lcsi_levels}{LCSI levels in that order: "None", "Stress", "Crisis", "Emergency.}
}
\value{
Two new columns with the FEWS NET Food Consumption-Livelihood Coping matrix phases: numbers (fclp) and categories (fclp_cat).
}
\description{
FEWS NET Food Consumption-Livelihood Coping Phase
}
\details{
\code{lcsi_cat_no_exhaustion} must be the categories column that was calculated without using the exhaustion of strategies choices when aggregating. See \code{lcsi()} and argument \code{with_exhaustion}. For calculation, see page 13 of the Fews Net matrix guidance available here: https://fews.net/sites/default/files/documents/reports/fews-net-matrix-guidance-document.pdf.
}
