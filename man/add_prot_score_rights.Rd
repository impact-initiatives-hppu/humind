% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_prot_score_rights.R
\name{add_prot_score_rights}
\alias{add_prot_score_rights}
\title{Add composite score for Ability to Access Rights and Services}
\usage{
add_prot_score_rights(
  df,
  sep = "/",
  prot_needs_1_services = "prot_needs_1_services",
  yes_healthcare = "yes_healthcare",
  yes_schools = "yes_schools",
  yes_gov_services = "yes_gov_services",
  yes_other_services = "yes_other_services",
  prot_needs_1_justice = "prot_needs_1_justice",
  yes_identity_documents = "yes_identity_documents",
  yes_counselling_legal = "yes_counselling_legal",
  yes_property_docs = "yes_property_docs",
  yes_gov_services_justice = "yes_gov_services",
  yes_other_services_justice = "yes_other_services",
  no = "no",
  dnk = "dnk",
  pnta = "pnta",
  .keep_weighted = FALSE
)
}
\arguments{
\item{df}{A data frame containing binary indicator columns for both questions.}

\item{sep}{Separator between question code and answer option in column names. Default: "/".}

\item{prot_needs_1_services}{Base name of services question. Default: "prot_needs_1_services".}

\item{yes_healthcare}{Answer option name for "Yes, accessing healthcare". Default: "yes_healthcare".}

\item{yes_schools}{Answer option name for "Yes, accessing schools". Default: "yes_schools".}

\item{yes_gov_services}{Answer option name for "Yes, accessing governmental services". Default: "yes_gov_services".}

\item{yes_other_services}{Answer option name for "Yes, accessing other services". Default: "yes_other_services".}

\item{prot_needs_1_justice}{Base name of justice question. Default: "prot_needs_1_justice".}

\item{yes_identity_documents}{Answer option name for "Yes, accessing identity and civil documents services". Default: "yes_identity_documents".}

\item{yes_counselling_legal}{Answer option name for "Yes, individual counselling or legal assistance". Default: "yes_counselling_legal".}

\item{yes_property_docs}{Answer option name for "Yes, accessing house, land and property documentation". Default: "yes_property_docs".}

\item{yes_gov_services_justice}{Answer option name for "Yes, accessing governmental services". Default: "yes_gov_services".}

\item{yes_other_services_justice}{Answer option name for "Yes, accessing other services". Default: "yes_other_services".}

\item{no}{Answer option name for "No". Default: "no".}

\item{dnk}{Answer option name for "Don't know"  Default: "dnk".}

\item{pnta}{Answer option name for "Prefer not to answer" Default: "pnta".}

\item{.keep_weighted}{Logical; if TRUE, retain intermediate weighted columns with suffix \verb{_w}. Default: FALSE.}
}
\value{
Input data frame with three new composite-score columns:
\itemize{
\item \code{comp_prot_score_prot_needs_1_services}: weighted sum of services options.
\item \code{comp_prot_score_prot_needs_1_justice}: weighted sum of justice options.
\item \code{comp_prot_score_needs_1}: overall severity (1–4) based on combined score.
Plus optional \verb{_w} columns if \code{.keep_weighted = TRUE}.
}
}
\description{
Computes weighted sums for two questions about household difficulties accessing services
and justice/legal resources, then derives an overall severity category (1–4).
}
