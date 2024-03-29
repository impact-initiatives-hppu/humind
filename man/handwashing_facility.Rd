% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/handwashing_facility.R
\name{handwashing_facility}
\alias{handwashing_facility}
\alias{handwashing_facility_score}
\title{Handwashing facility classification}
\usage{
handwashing_facility(
  df,
  handwashing_facility = "handwashing_facility",
  soap_and_water = c("yes_soap_water"),
  none = c("no", "yes_only_soap", "yes_only_water"),
  na = c("dnk", "no_access")
)

handwashing_facility_score(
  df,
  handwashing_facility_cat = "handwashing_facility_cat",
  handwashing_facility_levels = c("none", "soap_and_water")
)
}
\arguments{
\item{df}{A data frame.}

\item{handwashing_facility}{Component column: Handwashing facility types.}

\item{soap_and_water}{Character vector of responses codes, such as "Yes, available with soap and water (seen)" , e.g., c("yes_soap_water").}

\item{none}{Character vector of responses codes, such as "Yes, only soap", "Yes, only water" or "No", e.g., c("no", "yes_only_soap", "yes_only_water").}

\item{na}{Character vector of responses codes, such as "Don't know" or "No access", e.g., c("dnk","no_access").}

\item{handwashing_facility_cat}{Component column: Categories of handwashing facility.}

\item{handwashing_facility_levels}{Handwashing facility levels - in that order: none, soap and water.}
}
\value{
A data frame with a new column named \code{handwashing_facility_cat} (for \code{\link[=handwashing_facility]{handwashing_facility()}}) and \code{handwashing_facility_score} (for \code{\link[=handwashing_facility_score]{handwashing_facility_score()}}) appended.
}
\description{
\code{\link[=handwashing_facility]{handwashing_facility()}} recodes the types of handwasing facility, and \code{\link[=handwashing_facility_score]{handwashing_facility_score()}} classifies each household/individual on a 2-point scale.
}
\section{Details on the 2-point scale}{


The classification is computed as follows:
\itemize{
\item Level 2: No handwashing facility available, or only water or only soap available at handwashing facility;
\item Level 1: Handwashing facility available with soap and water;
}
}

