% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_shelter_damage_cat.R
\name{add_shelter_damage_cat}
\alias{add_shelter_damage_cat}
\title{Add Category of Shelter damage (Optional SNFI dimension)}
\usage{
add_shelter_damage_cat(
  df,
  sep = "/",
  snfi_shelter_damage = "snfi_shelter_damage",
  none = "none",
  minor = "minor",
  major = "major",
  damage_windows_doors = "damage_windows_doors",
  damage_floors = "damage_floors",
  damage_walls = "damage_walls",
  total_collapse = "total_collapse",
  other = "other",
  dnk = "dnk",
  pnta = "pnta"
)
}
\arguments{
\item{df}{Data frame containing the survey data.}

\item{sep}{Separator for the binary columns, default is "/".}

\item{snfi_shelter_damage}{Column name}

\item{none}{answer option}

\item{minor}{answer option}

\item{major}{answer option}

\item{damage_windows_doors}{answer option}

\item{damage_floors}{answer option}

\item{damage_walls}{answer option}

\item{total_collapse}{answer option}

\item{other}{answer option}

\item{dnk}{answer option}

\item{pnta}{answer option}
}
\value{
A data frame with an additional column:
\itemize{
\item snfi_shelter_damage_cat: Categorized shelter damages: "No damage", "Damaged", "Partial collapse or destruction", "Total collapse or destruction", or "Undefined".
}
}
\description{
This function categorizes the shelter damage category based on provided criteria.
}
