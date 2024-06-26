#' @title Add columns to use for calculation of the composite indicators
#' @description
#' Participation rate in organised learning (one year before the official primary entry age) (adjusted) -
#' Description: Percentage of children (one year before the official primary school entry age) who are attending an early childhood education programme or primary school
#' Early enrollment in primary grade
#' Percentage of children in the relevant age group (one year before the official primary school entry age) who are attending primary school
#' Net attendance rate (adjusted) -
#'   Percentage of school-aged children of
#' (d) primary school age currently attending primary, lower or upper secondary school
#' (e) lower secondary school age currently attending lower secondary school or higher
#' (f) upper secondary school age currently attending upper secondary school or higher
#' Over-age for grade -
#'   Percentage of school-aged children attending school who are at least 2 years above the intended age for grade
#' (a) Primary school
#' (b) Lower secondary school
#'
#'
#' @param roster A data frame of individual-level data.
#' @param country_assessment  Can input either country code or name, case-insensitive
#' @param education_access The individual access indicator column.
#' @param education_level_grade The individual level and grade column.
#'
#'
#' @return X new columns with the corrected individual age definition
#' @export


add_edu_level_grade_indicators  <- function(roster,
                                            country_assessment = 'BFA',
                                            education_access = 'education_access',
                                            education_level_grade = 'education_level_grade'){


  info_country_school_structure <- read_ISCED_info(country_assessment)
  summary_info_school <- info_country_school_structure$summary_info_school    # DataFrame 1: level code, Learning Level, starting age, duration
  levels_grades_ages <-  info_country_school_structure$levels_grades_ages     # DataFrame 2: level code, Learning Level, Year/Grade, Theoretical Start age, limit age



  # 'name_level_grade' is the new column name intended to provide a clearer description of the education levels and grades based on the school system
  roster <- roster %>%
    rename(!!"name_level_grade" := !!sym(education_level_grade))

  ## ----- levels_grades_ages manipulation
  # new column in levels_grades_ages df: limit_age = starting_age + 2. Used to calculate the overage learners
  levels_grades_ages <- levels_grades_ages %>%
    dplyr::mutate(limit_age = starting_age + 2)

  # Build summary_info_school equivalent
  summary_info_school <- summary_info_school %>%
    mutate(
      ending_age = if_else(
        level_code == max(level_code), # Check if it's the last level
        starting_age + duration,      # For the last level
        starting_age + duration - 1    # For all other levels
      )
    )

  ## left join to merge additional details from levels_grades_ages into roster based on matching 'name_level_grade' values.
  # 'anti_join' to find and isolate records in roster that do not have a corresponding match in levels_grades_ages based on 'name_level_grade'.
  # If unmatched grades are found, a warning message is then constructed, explicitly listing all unique unmatched 'name_level_grade' values found
  roster <- left_join(roster, levels_grades_ages, by = "name_level_grade") %>%
    select(uuid, person_id, everything())

  unmatched_grades <- anti_join(roster, levels_grades_ages, by = "name_level_grade") %>%
    filter(!is.na(name_level_grade) & name_level_grade != "")

  if (nrow(unmatched_grades) > 0) {
    unmatched_list <- unique(unmatched_grades$name_level_grade)
    warning_message <- sprintf("A level and grade were recorded in the data that are not present in the list of levels and grades coded for the country. Please review the unmatched 'name_level_grade' values: %s",
                               paste(unmatched_list, collapse = ", "))
    warning(warning_message)
  }


  ## ------ Dynamically create info data frames for each school level based on the number of levels
  school_level_infos <- list()
  # Extract unique level codes sorted if needed
  unique_levels <- sort(unique(summary_info_school$level_code))
  # Iterate through each row of summary_info_school to populate school_level_infos
  for (i in seq_len(nrow(summary_info_school))) {
    level_info <- summary_info_school[i, ]
    level_code <- level_info$level_code

    # Create a list for each level with the required information
    school_level_info <- list(
      level = level_code,
      starting_age = level_info$starting_age,
      ending_age = if_else(level_info$level_code == max(summary_info_school$level_code),
                           level_info$starting_age + level_info$duration, # If it's the last level, do not subtract 1
                           level_info$ending_age) # For all other levels, use the ending_age as is
    )
    # Assign to school_level_infos using level_code as the name
    school_level_infos[[level_code]] <- school_level_info
  }

  ## ---- Ensure continuous age ranges between levels and all levels being present
  validate_age_continuity_and_levels(school_level_infos, unique_levels)
  validate_level_code_name_consistency(summary_info_school)
  validate_grade_continuity_within_levels(levels_grades_ages)

  ## Adjusting level_code, name_level, and grade Based on education_access
  # If education_access for a record is either NA or 0. the values in level_code, name_level, and grade for that record are set to NA.
  # This effectively removes specific educational details when there is no access to education, ensuring that subsequent data analysis on these columns only considers valid, relevant educational data.
  roster <- roster %>%
    mutate(across(c(level_code, name_level, grade), ~if_else(is.na(education_access) | education_access == 0, NA_character_, .)))

  # remove level 0
  filtered_levels <- unique_levels[-1]
  true_age_col <- "edu_ind_corrected_age"  # Direct assignment


  for (level in filtered_levels) {
    # Extract info for current level
    starting_age <- as.numeric(school_level_infos[[level]]$starting_age)
    ending_age <- as.numeric(school_level_infos[[level]]$ending_age)

    # Define dynamic column names
    age_col_name <- paste0('edu_',level, "_age")
    roster[[age_col_name]] <- ifelse(roster[[true_age_col]] >= starting_age & roster[[true_age_col]] <= ending_age, 1, 0)
  }

  ## ----- NUM and DEN for:  % of children (one year before the official primary school entry age) who are attending an early childhood education program or primary school
  roster <- roster %>%
    mutate(
      # Adjust age conditionally, checking for NA in true_age_col
      edu_level1_minus_one_age = if_else(is.na(!!sym(true_age_col)),
                                         NA_integer_,
                                         if_else(!!sym(true_age_col) == (school_level_infos[['level1']]$starting_age - 1), 1, 0),
                                         missing = NA_integer_),

      # Calculate participation rate, setting to NA if true_age_col is NA
      edu_attending_level0_level1_and_level1_minus_one_age = if_else(is.na(!!sym(true_age_col)),
                                                                     NA_integer_,
                                                                     if_else(!!sym(true_age_col) == (school_level_infos[['level1']]$starting_age - 1)
                                                                             & (!!sym('level_code') == 'level0' | !!sym('level_code') == 'level1'), 1, 0),
                                                                     missing = NA_integer_),

      # Early enrollment checking, setting to NA if true_age_col is NA
      edu_attending_level1_and_level1_minus_one_age = if_else(is.na(!!sym(true_age_col)),
                                                              NA_integer_,
                                                              if_else(!!sym(true_age_col) == (school_level_infos[['level1']]$starting_age - 1)
                                                                      & !!sym('level_code') == 'level1', 1, 0),
                                                              missing = NA_integer_)
    )


  ## ----- NUM and DEN for:  Net attendance rate (adjusted) - % of school-aged children of level school age currently attending levels
  level_numeric <- seq_along(filtered_levels)
  names(level_numeric) <- filtered_levels

  for (level in filtered_levels) {
    starting_age <- as.numeric(school_level_infos[[level]]$starting_age)
    ending_age <- as.numeric(school_level_infos[[level]]$ending_age)
    #
    higher_levels_numeric <- gsub("level", "",  paste(filtered_levels[which(filtered_levels >= level)], collapse = ""))
    attending_col_name <- paste0("edu_attending_level", higher_levels_numeric, "_and_", level, "_age")
    #
    roster[[attending_col_name]] <- ifelse(  roster[[true_age_col]] >= starting_age & roster[[true_age_col]] <= ending_age & as.integer(as.factor(roster$level_code)) >= level_numeric[[level]],1, 0 )
  }

  filtered_levels_overage <- filtered_levels[filtered_levels %in% c("level1", "level2")]
  ## ----- NUM and DEN for: Percentage of school-aged children attending school who are at least 2 years above the intended age for grade: primary/lower secondary

  # Loop through each level to set flags for attendance at each level
  for (level in filtered_levels_overage) {
    accessing_level_col_name <- paste0('edu_attending_', level)
    roster[[accessing_level_col_name]] <- if_else(roster[['level_code']] == level, 1, 0, missing = NA_integer_)
  }

  # Loop through each level to calculate the numerator for overage learners
  for (level in filtered_levels_overage) {
    overage_level_col_name <- paste0('edu_', level, "_overage_learners")
    roster[[overage_level_col_name]] <- ifelse(roster[['level_code']] == level &
                                                 (roster[[true_age_col]] - roster[['limit_age']]) >= 2, 1, 0)
  }


  return(roster)


}
