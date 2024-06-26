#' @title Add a column edu_school_cycle
#'
#'
#' @param roster A data frame of individual-level data.
#' @param country_assessment  Can input either country code or name, case-insensitive
#'
#'
#' @return X new columns with the corrected individual age definition
#' @export


add_edu_school_cycle <- function(roster, country_assessment = 'BFA') {
  # Read school structure information for the specified country
  info_country_school_structure <- read_ISCED_info(country_assessment)
  summary_info_school <- info_country_school_structure$summary_info_school    # DataFrame 1: level code, Learning Level, starting age, duration
  levels_grades_ages <-  info_country_school_structure$levels_grades_ages     # DataFrame 2: level code, Learning Level, Year/Grade, Theoretical Start age, limit age

  # Adjust limit age in levels_grades_ages
  levels_grades_ages <- levels_grades_ages %>%
    dplyr::mutate(limit_age = starting_age + 2)

  # Compute ending ages for each educational level in summary_info_school
  summary_info_school <- summary_info_school %>%
    mutate(
      ending_age = if_else(
        level_code == max(level_code),  # Check if it's the last level
        starting_age + duration,       # For the last level
        starting_age + duration - 1     # For all other levels
      )
    )

  conditions <- list()

  # Loop through each row of the summary_info_school to create conditions
  for (i in seq_len(nrow(summary_info_school))) {
    level_info <- summary_info_school[i, ]
    starting_age <- level_info$starting_age
    ending_age <- level_info$ending_age
    name_level <- if (i == 1) "ECE" else level_info$name_level  # Force "ECE" for the first level

    # Append the condition to the list
    conditions[[length(conditions) + 1]] <- expr(
      edu_ind_corrected_age >= !!starting_age & edu_ind_corrected_age <= !!ending_age ~ !!name_level
    )
  }

  # Add a default condition for any age outside the defined ranges
  conditions[[length(conditions) + 1]] <- expr(TRUE ~ NA_character_)

  # Apply all conditions using case_when in a single mutate to determine the school cycle
  roster <- roster %>%
    mutate(edu_school_cycle = dplyr::case_when(!!!conditions))

  return(roster)
}


