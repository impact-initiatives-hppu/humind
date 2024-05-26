#' Add received assistance (combined calculation)
#'
#' @param df A data frame.
#' @param received_assistance_12m Column name for received assistance in the last 12 months.
#' @param yes Value for yes.
#' @param no Value for no.
#' @param undefined Vector of undefined responses.
#' @param received_assistance_date Column name for the recall period when the assistance was received.
#' @param date_past_30d Value for received assistance in the past 30 days.
#' @param date_1_3_months Value for received assistance in the last 1-3 months.
#' @param date_4_6_months Value for received assistance in the last 4-6 months.
#' @param date_7_12_months Value for received assistance in the last 7-12 months.
#' @param date_undefined Vector of undefined responses for the date of received assistance.
#'
#' @export
add_received_assistance <- function(
    df,
    received_assistance_12m = "aap_received_assistance_12m",
    yes = "yes",
    no = "no",
    undefined = c("dnk", "pnta"),
    received_assistance_date = "aap_received_assistance_date",
    date_past_30d = "past_30d",
    date_1_3_months = "1_3_months",
    date_4_6_months = "4_6_months",
    date_7_12_months = "7_12_months",
    date_undefined = c("dnk", "pnta")){

  #------ Checks

  # Check if vars are in df
  if_not_in_stop(df, c(received_assistance_12m, received_assistance_date), "df")

  # Check if all values are in set
  are_values_in_set(df, received_assistance_12m, c(yes, no, undefined))
  are_values_in_set(df, received_assistance_date, c(date_past_30d, date_1_3_months, date_4_6_months, date_7_12_months, date_undefined))

  # Check if yes and no a re of length 1
  if (length(yes) != 1 | length(no) != 1) {
    stop("yes and no must be of length 1.")
  }

  #------ Add

  # Add received assistance
  df <- dplyr::mutate(
    df,
    aap_received_assistance = dplyr::case_when(
      !!rlang::sym(received_assistance_12m) %in% undefined ~ "undefined",
      !!rlang::sym(received_assistance_date) %in% undefined ~ "undefined",
      !!rlang::sym(received_assistance_12m) == no ~ "no",
      !!rlang::sym(received_assistance_12m) == yes & !!rlang::sym(received_assistance_date) %in% date_past_30d ~ "past_30d",
      !!rlang::sym(received_assistance_12m) == yes & !!rlang::sym(received_assistance_date) %in% date_1_3_months ~ "1_3_months",
      !!rlang::sym(received_assistance_12m) == yes & !!rlang::sym(received_assistance_date) %in% date_4_6_months ~ "4_6_months",
      !!rlang::sym(received_assistance_12m) == yes & !!rlang::sym(received_assistance_date) %in% date_7_12_months ~ "7_12_months",
      .default = NA_character_
    )
  )

  return(df)

}
