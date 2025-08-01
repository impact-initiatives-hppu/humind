% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_fds_cannot_cat.R
\name{add_fds_cannot_cat}
\alias{add_fds_cannot_cat}
\title{Add Functional Domestic Space Tasks Categories}
\usage{
add_fds_cannot_cat(
  df,
  fds_cooking = "snfi_fds_cooking",
  fds_cooking_can = "no",
  fds_cooking_cannot = "yes",
  fds_cooking_no_need = "no_need",
  fds_cooking_undefined = "pnta",
  fds_sleeping = "snfi_fds_sleeping",
  fds_sleeping_can = "yes",
  fds_sleeping_cannot = "no",
  fds_sleeping_undefined = "pnta",
  fds_storing = "snfi_fds_storing",
  fds_storing_cannot = "no",
  fds_storing_can = c("yes_issues", "yes_no_issues"),
  fds_storing_undefined = "pnta",
  lighting_source = "energy_lighting_source",
  lighting_source_none = "none",
  lighting_source_undefined = c("pnta", "dnk")
)
}
\arguments{
\item{df}{A data frame containing the input columns}

\item{fds_cooking}{Column name for cooking tasks}

\item{fds_cooking_can}{Value for can perform cooking tasks without issues}

\item{fds_cooking_cannot}{Value for facing issues when cooking}

\item{fds_cooking_no_need}{Value for no need to perform cooking tasks}

\item{fds_cooking_undefined}{Vector of undefined responses for cooking tasks}

\item{fds_sleeping}{Column name for sleeping tasks}

\item{fds_sleeping_can}{Value for can perform sleeping tasks}

\item{fds_sleeping_cannot}{Value for cannot perform sleeping tasks}

\item{fds_sleeping_undefined}{Vector of undefined responses for sleeping tasks}

\item{fds_storing}{Column name for storing tasks}

\item{fds_storing_cannot}{Value for cannot perform storing tasks}

\item{fds_storing_can}{Value for can perform storing tasks}

\item{fds_storing_undefined}{Vector of undefined responses for storing tasks}

\item{lighting_source}{Column name for lighting source}

\item{lighting_source_none}{Value for no lighting source}

\item{lighting_source_undefined}{Vector of undefined responses for lighting source}
}
\value{
A data frame with additional columns:
\itemize{
\item snfi_fds_cooking: Standardized categories for cooking tasks
\item snfi_fds_sleeping: Standardized categories for sleeping tasks
\item snfi_fds_storing: Standardized categories for storing tasks
\item energy_lighting_source: Standardized categories for lighting source
\item snfi_fds_cannot_n: Number of tasks that cannot be performed
\item snfi_fds_cannot_cat: Categorized number of tasks that cannot be performed
}
}
\description{
This function adds categories for functional domestic space tasks based on various input parameters.
It processes cooking, sleeping, storing, and lighting tasks, creating new columns with standardized categories and a summary of tasks that cannot be performed.
}
