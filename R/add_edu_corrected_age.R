#' @title Add column edu_ind_corrected_age with the revised and corrected individual age according to the start of the data collection wrt the start f the school-year
#' Add a column edu_is_school_child

#' @param roster A data frame of individual-level data.
#' @param household_data A data frame of hh-level data.
#' @param age_col The individual age column.
#' @param start_school_year numeric. it is the month when the school year has started.
#' @return 2 new columns with the corrected individual age definition and dummy edu_is_school_child
#' @export



add_edu_corrected_age <- function(roster, household_data, start_school_year = 9, age_col = 'ind_age') {
  # Convert the 'start' column to month and create a new data frame
  df <- household_data %>%
    mutate(month = as.integer(format(as.Date(start), "%m")))

  # Join df to roster
  roster <- roster %>%
    left_join(select(df, uuid, month), by = "uuid")

  # Calculate the adjusted start month number
  adjusted_start_month_num <- ifelse(start_school_year > 6, start_school_year - 12, start_school_year)

  roster[[age_col]] <- as.numeric(roster[[age_col]])

  # Apply the age correction based on the month difference, handling NA in month or age
  roster <- roster %>%
    mutate(edu_ind_corrected_age = ifelse(!is.na(month) & !is.na(!!sym(age_col)) & (month - adjusted_start_month_num) > 6,
                                          !!sym(age_col) - 1,
                                          !!sym(age_col)))
  roster <- roster %>%
    mutate(edu_ind_corrected_age = ifelse(edu_ind_corrected_age < 5 | edu_ind_corrected_age > 17, NA_real_, edu_ind_corrected_age))


  roster <- roster %>%
    mutate(edu_is_school_child = if_else(is.na(edu_ind_corrected_age) | (edu_ind_corrected_age < 5 | edu_ind_corrected_age > 17), 0, 1))

  # Optionally, remove the month column if it's no longer needeS
  roster <- roster %>% select(-month)
  return (roster)
}

