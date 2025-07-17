#' Rank Top 3 Infrequent Expenditure Types
#'
#' @title Rank Top 3 Infrequent Expenditure Types
#'
#' @description
#' This function ranks the top 3 most infrequent expenditure types for each household
#' based on the amount spent on various categories. It adds new columns to the input
#' data frame indicating the top 3 infrequent expenditure types.
#'
#' Prerequisite function:
#'
#' * add_expenditure_type_zero_infreq.R
#'
#' @param df A data frame containing infrequent expenditure data for households.
#' @param expenditure_infreq_types A character vector. The names of the columns that contain the amount of infrequent expenditures types.
#' @param id_col The name of the column that contains the unique identifier.
#'
#' @return A data frame with additional columns:
#'
#' * cm_infreq_expenditure_top1: The most infrequent expenditure type.
#' * cm_infreq_expenditure_top2: The second most infrequent expenditure type.
#' * cm_infreq_expenditure_top3: The third most infrequent expenditure type.
#'
#' @export
add_expenditure_type_infreq_rank <- function(
  df,
  expenditure_infreq_types = c(
    "cm_expenditure_infrequent_shelter",
    "cm_expenditure_infrequent_nfi",
    "cm_expenditure_infrequent_health",
    "cm_expenditure_infrequent_education",
    "cm_expenditure_infrequent_debt",
    "cm_expenditure_infrequent_clothing",
    "cm_expenditure_infrequent_other"
  ),
  id_col = "uuid"
) {
  #------ Checks

  # Check if the columns exist
  if_not_in_stop(df, expenditure_infreq_types, "df")

  # Check that all infrequent expenditure types are here
  if (length(expenditure_infreq_types) < 7) {
    rlang::abort("Some of the infrequent expenditure types are null.")
  }

  # Check that expenditure types are numeric
  are_cols_numeric(df, expenditure_infreq_types)

  #------ Ranking

  df <- rank_top3_vars(
    df = df,
    vars = c(expenditure_infreq_types),
    new_colname_top1 = "cm_infreq_expenditure_top1",
    new_colname_top2 = "cm_infreq_expenditure_top2",
    new_colname_top3 = "cm_infreq_expenditure_top3",
    id_col = id_col
  )

  return(df)
}
