% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_expenditure_type_prop_infreq.R
\name{add_expenditure_type_prop_infreq}
\alias{add_expenditure_type_prop_infreq}
\title{Add Infrequent Expenditure Type Proportions}
\usage{
add_expenditure_type_prop_infreq(
  df,
  cm_expenditure_infrequent_shelter = "cm_expenditure_infrequent_shelter",
  cm_expenditure_infrequent_nfi = "cm_expenditure_infrequent_nfi",
  cm_expenditure_infrequent_health = "cm_expenditure_infrequent_health",
  cm_expenditure_infrequent_education = "cm_expenditure_infrequent_education",
  cm_expenditure_infrequent_debt = "cm_expenditure_infrequent_debt",
  cm_expenditure_infrequent_clothing = "cm_expenditure_infrequent_clothing",
  cm_expenditure_infrequent_other = "cm_expenditure_infrequent_other"
)
}
\arguments{
\item{df}{A data frame containing infrequent expenditure data.}

\item{cm_expenditure_infrequent_shelter}{Column name for shelter maintenance or repair expenditure amount.}

\item{cm_expenditure_infrequent_nfi}{Column containing expenditure amount for non-food household items for infrequent purchase, such as blankets, cooking pots, clothing, etc.}

\item{cm_expenditure_infrequent_health}{Column name for health-related expenditures, such as healthcare, medicine, etc.}

\item{cm_expenditure_infrequent_education}{Column name for education-related expenditures, such school fees, supplies, uniforms, etc.}

\item{cm_expenditure_infrequent_debt}{Column containing expenditure amount for debt repayment.}

\item{cm_expenditure_infrequent_clothing}{Column containing expenditure amount for clothing.}

\item{cm_expenditure_infrequent_other}{Column name for all other infrequent expenditures.}
}
\value{
A data frame with additional columns:
\itemize{
\item cm_expenditure_infrequent_total: The total infrequent expenditure amount.
\item cm_expenditure_infrequent_shelter_prop: Proportion of shelter maintenance or repair expenditure.
\item cm_expenditure_infrequent_nfi_prop: Proportion of non-food household items expenditure.
\item cm_expenditure_infrequent_health_prop: Proportion of health-related expenditures.
\item cm_expenditure_infrequent_education_prop: Proportion of education-related expenditures.
\item cm_expenditure_infrequent_debt_prop: Proportion of debt repayment expenditure.
\item cm_expenditure_infrequent_clothing_prop: Proportion of clothing-related expenditure.
\item cm_expenditure_infrequent_other_prop: Proportion of other infrequent expenditures.
}
}
\description{
This function calculates the proportion of each infrequent expenditure type
relative to the total infrequent expenditure. It adds new columns to the input
data frame representing these proportions.

Prerequisite function:
\itemize{
\item add_expenditure_type_zero_infreq.R
}
}
