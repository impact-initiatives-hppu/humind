% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_handwashing_facility_cat.R
\name{add_handwashing_facility_cat}
\alias{add_handwashing_facility_cat}
\title{Add handwashing facility category - "Basic," "Limited," or "No facility."}
\usage{
add_handwashing_facility_cat(
  df,
  survey_modality = "survey_modality",
  survey_modality_in_person = c("in_person"),
  survey_modality_remote = c("remote"),
  facility = "wash_handwashing_facility",
  facility_yes = "available",
  facility_no = "none",
  facility_no_permission = "no_permission",
  facility_undefined = "other",
  facility_observed_water = "wash_handwashing_facility_observed_water",
  facility_observed_water_yes = "water_available",
  facility_observed_water_no = "water_not_available",
  facility_observed_soap = "wash_handwashing_facility_observed_soap",
  facility_observed_soap_yes = "soap_available",
  facility_observed_soap_no = "soap_not_available",
  facility_observed_soap_alternative = "alternative_available",
  facility_reported = "wash_handwashing_facility_reported",
  facility_reported_yes = c("fixed_dwelling", "fixed_yard", "mobile"),
  facility_reported_no = c("none"),
  facility_reported_undefined = c("other", "dnk", "pnta"),
  facility_reported_no_permission_soap = "wash_soap_observed",
  facility_reported_no_permission_soap_yes = c("yes_soap_shown", "yes_soap_not_shown"),
  facility_reported_no_permission_soap_no = "no",
  facility_reported_no_permission_soap_undefined = c("dnk", "pnta"),
  facility_reported_no_permission_soap_type = "wash_soap_observed_type",
  facility_reported_no_permission_soap_type_yes = c("soap", "detergent"),
  facility_reported_no_permission_soap_type_no = "ash_mud_sand",
  facility_reported_no_permission_soap_type_undefined = c("other", "dnk", "pnta"),
  facility_reported_remote_soap = "wash_soap_reported",
  facility_reported_remote_soap_yes = "yes",
  facility_reported_remote_soap_no = "no",
  facility_reported_remote_soap_undefined = c("dnk", "pnta"),
  facility_reported_remote_soap_type = "wash_soap_reported_type",
  facility_reported_remote_soap_type_yes = c("soap", "detergent"),
  facility_reported_remote_soap_type_no = c("ash_mud_sand"),
  facility_reported_remote_soap_type_undefined = c("other", "dnk", "pnta")
)
}
\arguments{
\item{df}{Data frame containing the survey data.}

\item{survey_modality}{Column name for the survey modality - e.g., "survey_modality".}

\item{survey_modality_in_person}{Options for the in-person survey modality.}

\item{survey_modality_remote}{Options for the remote survey modality.}

\item{facility}{Column name for the observed handwashing facility - e.g., "wash_handwashing_facility".}

\item{facility_yes}{Response code for yes.}

\item{facility_no}{Response code for no.}

\item{facility_no_permission}{Response code for no permission.}

\item{facility_undefined}{Response code for undefined.}

\item{facility_observed_water}{Column name for the observed handwashing facility - e.g., "wash_handwashing_facility_observed_water".}

\item{facility_observed_water_yes}{Response code for yes.}

\item{facility_observed_water_no}{Response code for no.}

\item{facility_observed_soap}{Column name for the observed handwashing facility - e.g., "wash_handwashing_facility_observed_soap".}

\item{facility_observed_soap_yes}{Response code for yes.}

\item{facility_observed_soap_no}{Response code for no.}

\item{facility_observed_soap_alternative}{Response code for alternative.}

\item{facility_reported}{Column name for the reported handwashing facility.}

\item{facility_reported_yes}{Response code for yes.}

\item{facility_reported_no}{Response code for no.}

\item{facility_reported_undefined}{Response code for undefined.}

\item{facility_reported_no_permission_soap}{Column name for the reported handwashing facility.}

\item{facility_reported_no_permission_soap_yes}{Response code for yes.}

\item{facility_reported_no_permission_soap_no}{Response code for no.}

\item{facility_reported_no_permission_soap_undefined}{Response code for undefined.}

\item{facility_reported_no_permission_soap_type}{Column name for the type of soap reported}

\item{facility_reported_no_permission_soap_type_yes}{Response code for yes.}

\item{facility_reported_no_permission_soap_type_no}{Response code for no.}

\item{facility_reported_no_permission_soap_type_undefined}{Response code for undefined.}

\item{facility_reported_remote_soap}{Column name for the availability of soap reported in remote cases.}

\item{facility_reported_remote_soap_yes}{Response code for yes.}

\item{facility_reported_remote_soap_no}{Response code for no.}

\item{facility_reported_remote_soap_undefined}{Response code for undefined.}

\item{facility_reported_remote_soap_type}{Column name for the type of soap reported in remote cases.}

\item{facility_reported_remote_soap_type_yes}{Response code for yes.}

\item{facility_reported_remote_soap_type_no}{Response code for no.}

\item{facility_reported_remote_soap_type_undefined}{Response code for undefined.}
}
\description{
Add handwashing facility category - "Basic," "Limited," or "No facility."
}
