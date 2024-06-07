
#------------------------------------------------ Functions to read the "edu_ISCED/UNESCO ISCED Mappings_MSNAcountries_consolidated.xlsx" and create 2 dataframes with the school-info
read_school_level_grade_age <- function(file_path, country_input) {
  # Read the Excel file
  df <- readxl::read_excel(file_path, sheet = "Compiled_Levels_Grades")
  
  # Convert the country input and dataframe columns to lowercase for case-insensitive comparison
  country_input_lower <- tolower(country_input)
  
  # Check if the country exists in the dataframe
  if(sum(tolower(df$`country code`) == country_input_lower | tolower(df$country) == country_input_lower) == 0){
    warning(sprintf("The country '%s' does not exist in the dataset.", country_input))
    return(NULL)
  }
  
  # Filter data for the specified country by code or name, case-insensitive
  country_df <- dplyr::filter(df, tolower(`country code`) == country_input_lower | tolower(country) == country_input_lower)
  
  # DataFrame 1: level code, Learning Level, starting age, duration
  df1 <- country_df %>%
    dplyr::group_by(`level code`, `learning level`) %>%
    dplyr::summarise(starting_age = min(`theoretical start age`),
                     duration = dplyr::n(),
                     .groups = 'drop')
  
  # Adjust for level0 duration if both level0 and level1 exist
  if ("level0" %in% df1$`level code` && "level1" %in% df1$`level code`) {
    starting_age_level0 <- df1$starting_age[df1$`level code` == "level0"]
    starting_age_level1 <- df1$starting_age[df1$`level code` == "level1"]
    duration_level0 <- starting_age_level1 - starting_age_level0
    
    df1 <- df1 %>%
      mutate(duration = ifelse(`level code` == "level0", duration_level0, duration))
  }

  # DataFrame 2: level code, Learning Level, Year/Grade, Theoretical Start age, limit age
  df2 <- country_df %>%
    dplyr::select(`level code`, `learning level`, `year-grade`, `theoretical start age`,  `name -- for kobo`)
  
  df2 <- df2 %>%
    rename(
      level_code = `level code`,
      name_level = `learning level`,
      starting_age = `theoretical start age`,
      name_level_grade = `name -- for kobo`,
      grade = `year-grade`
    )
  
  df1 <- df1 %>%
    rename(
      level_code = `level code`,
      name_level = `learning level`
    )
  
  return(list(df1 = df1, df2 = df2))
}#--------------------------------------------------------------------------------------------------------


#------------------------------------------------ Function to Replace yes/no with 0 and 1
modify_column_value_yes_no <- function(data, target_cols) {
  # Ensure target_cols is a character vector
  target_cols <- as.character(target_cols)
  
  # Check if target_cols exist in data
  missing_cols <- target_cols[!target_cols %in% names(data)]
  if (length(missing_cols) > 0) {
    warning("The following columns were not found in data: ", paste(missing_cols, collapse = ", "), ". No changes made.")
    return(data)
  }
  
  # Process each target column
  data <- data %>%
    mutate(across(all_of(target_cols), 
                  ~ case_when(
                    is.na(.) ~ NA_character_,
                    . %in% c("yes", "Yes", "oui") ~ "1",
                    . %in% c("no", "No", "non") ~ "0",
                    . %in% c("dnk",'idk', "nsp", "dont_know", "no_answer") ~ "50",
                    . %in% c("pnta", "pnpr", "prefer_not_to_answer") ~ "99",
                    TRUE ~ as.character(.)
                  ))) %>%
    mutate(across(all_of(target_cols), as.numeric))
  
  return(data)
}#--------------------------------------------------------------------------------------------------------


#------------------------------------------------ Function to Replace all the different gender labels with 1 == MALE and 2 == FEMALE
modify_gender_values <- function(data, target_col) {
  # Check if target_col exists in data
  if (!target_col %in% names(data)) {
    warning(paste("Column", target_col, "not found in data. No changes made."), call. = FALSE)
    return(data)
  }
  
  # Replace gender labels with standardized numeric codes
  data <- data %>%
    mutate(!!target_col := case_when(
      is.na(.data[[target_col]]) ~ NA_integer_, # Keeps NA values as NA
      tolower(.data[[target_col]]) %in% c("femme", "féminin", "feminin", "female", "woman", "girl", "2") ~ 2L,
      tolower(.data[[target_col]]) %in% c("homme", "masculin", "masculin", "male", "man", "boy", "1") ~ 1L,
      .data[[target_col]] %in% c("no_answer") ~ 50L,
      .data[[target_col]] %in% c("other", "prefer_not_to_answer") ~ 99L,
      TRUE ~ NA_integer_ # If none of the above conditions are met, set to NA
    ))
  
  return(data)
}#--------------------------------------------------------------------------------------------------------



#------------------------------------------------ Function to determine if age correction should be applied
calculate_age_correction <- function(start_month, collection_month) {
  month_lookup <- setNames(seq(1, 12), tolower(substr(month.name, 1, 3)))
  
  # Convert month names to their numeric equivalents using the predefined lookup
  start_month_num <- month_lookup[tolower(substr(trimws(start_month), 1, 3))]
  collection_month_num <- month_lookup[tolower(substr(trimws(collection_month), 1, 3))]
  
  # Adjust the start month number for a school year starting in the previous calendar year
  adjusted_start_month_num <- if(start_month_num > 6) start_month_num - 12 else start_month_num
  
  # Determine if the age correction should be applied based on the month difference
  age_correction <- (collection_month_num - adjusted_start_month_num) > 6
  return(unname(age_correction))
}#--------------------------------------------------------------------------------------------------------



#------------------------------------------------ Functions to safely rename columns if they exist
safe_rename <- function(dataframe, old_name, new_name) {
  if(old_name %in% names(dataframe)) {
    dataframe <- rename(dataframe, !!new_name := !!sym(old_name))
  }
  return(dataframe)
}#--------------------------------------------------------------------------------------------------------



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






