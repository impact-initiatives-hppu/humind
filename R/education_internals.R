
#------------------------------------------------ Function to Ensure Continuous Age Ranges Between Levels
validate_age_continuity_and_levels <- function(school_level_infos, required_levels) {
  all_levels_df <- bind_rows(school_level_infos, .id = "level")
  # Check for missing levels
  existing_levels <- unique(all_levels_df$level)
  missing_levels <- setdiff(required_levels, existing_levels)
  if (length(missing_levels) > 0) {
    stop(sprintf("Missing required educational levels: %s", paste(missing_levels, collapse=", ")), call. = FALSE)
  }
  # Sorting might be necessary depending on your data
  all_levels_df <- all_levels_df %>% arrange(starting_age)
  # Continue with the continuity check
  for (i in 2:nrow(all_levels_df)) {
    if (all_levels_df$starting_age[i] != all_levels_df$ending_age[i-1] + 1) {
      stop(sprintf("Age range discontinuity between levels: %s ends at %d, but %s starts at %d, check the name_level for name_consistency, too",
                   all_levels_df$level[i-1], all_levels_df$ending_age[i-1],
                   all_levels_df$level[i], all_levels_df$starting_age[i]), call. = FALSE)
    }
  }
  return(TRUE)
}#--------------------------------------------------------------------------------------------------------



#------------------------------------------------ Function to Ensure Continuous Age Ranges within Levels
validate_grade_continuity_within_levels <- function(levels_grades_ages) {
  # Check for and correct any NA or "" column names.
  names(levels_grades_ages) <- ifelse(names(levels_grades_ages) == "" | is.na(names(levels_grades_ages)), paste0("V", 1:ncol(levels_grades_ages)), names(levels_grades_ages))

  levels_grades_ages <- levels_grades_ages %>%
    arrange(level_code, starting_age) %>%
    mutate(starting_age = as.numeric(starting_age))  # Ensure starting_age is numeric for comparison.

  unique_levels <- unique(levels_grades_ages$level_code)

  for (level in unique_levels) {
    if (level == "level0") {
      next  # Skip level0 as requested.
    }
    grades_in_level <- filter(levels_grades_ages, level_code == level)
    # If there's only one grade in the level, skip the checks.
    if (nrow(grades_in_level) < 2) {
      next
    }

    # Direct comparison for grades with the same starting_age within a level.
    for (i in 1:(nrow(grades_in_level) - 1)) {
      for (j in (i + 1):nrow(grades_in_level)) {
        if (grades_in_level$starting_age[i] == grades_in_level$starting_age[j]) {
          stop(sprintf("Error: Grades '%s' and '%s' within level %s have the same starting age of %d.",
                       grades_in_level$name_level_grade[i], grades_in_level$name_level_grade[j], level, grades_in_level$starting_age[i]), call. = FALSE)
        }
      }
    }

    # Check for non-consecutive starting ages.
    for (i in 2:nrow(grades_in_level)) {
      if (grades_in_level$starting_age[i] != grades_in_level$starting_age[i-1] + 1) {
        stop(sprintf("Continuity error between '%s' and '%s' in level %s: starting ages are not consecutive.",
                     grades_in_level$name_level_grade[i-1], grades_in_level$name_level_grade[i], level), call. = FALSE)
      }
    }
  }

  return(TRUE)
}#--------------------------------------------------------------------------------------------------------



#------------------------------------------------ Function to Ensure consistency between level codes and names
validate_level_code_name_consistency <- function(school_level_infos) {
  # Ensure the input is a dataframe
  if (!is.data.frame(school_level_infos)) {
    stop("The input must be a dataframe.")
  }

  # Check if the dataframe has the required columns
  if (!all(c("level_code", "name_level") %in% names(school_level_infos))) {
    stop("Dataframe must contain the columns: 'level_code' and 'name_level'.")
  }

  # Checking for inconsistent name_level within the same level_code
  inconsistent_levels <- school_level_infos %>%
    group_by(level_code) %>%
    summarise(unique_names = n_distinct(name_level)) %>%
    filter(unique_names > 1)

  if (nrow(inconsistent_levels) > 0) {
    inconsistent_detail <- school_level_infos %>%
      group_by(level_code) %>%
      summarise(name_levels = toString(unique(name_level))) %>%
      filter(level_code %in% inconsistent_levels$level_code)

    print(inconsistent_detail)
    stop("Validation failed due to inconsistencies in level_code and name_level associations.", call. = FALSE)
  } else {
    message("All level_code values are consistently associated with a single name_level. Validation passed.")
  }
}#--------------------------------------------------------------------------------------------------------






