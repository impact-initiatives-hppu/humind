#' @title Prepare dummy variables for education indicators (individual data)
#'
#'
#' @param country_assessment  Can input either country code or name, case-insensitive
#' @param roster A data frame of individual-level data.
#' @param household_data A data frame of hh-level data.
#' @param representative_admin_level Specifies the administrative level at which the desired disaggregation of data will occur
#' @param pop_group The population group column.
#' @param ind_age The individual age column.
#' @param ind_gender The individual gender column.
#' @param education_access The individual access indicator column.
#' @param education_level_grade The individual level and grade column.
#' @param education_disrupted_climate The education disrupted by climate-related hazards such as flood, cyclone, drought, or wildfire  column.
#' @param education_disrupted_teacher The education is disrupted by the teacher's absence column.
#' @param education_disrupted_displaced The education disrupted by school used as a shelter by displaced person column.
#' @param education_disrupted_occupation The education disrupted by school occupied by armed forces/ non-state armed groups column.
#' @param education_barrier the barrier column, select one, only for individual analysis.
#' 
#' @param start_school_year Character with the name of the month when the school year has started.
#' @param beginning_data_collection Character with the name of the month when the data collection has started.
#' 
#' @param roster_wgss roster containing the WGSS data, if the WGSS data were collected. If the WGSS indicators are included in the same roster loop, please re-write here the roster df
#' @param disability_seeing wgss variable for sight 
#' @param disability_hearing wgss variable for hearing 
#' @param disability_walking wgss variable for motor mobility 
#' @param disability_remembering wgss variable for remembering 
#' @param disability_selfcare wgss variable for selfcare 
#' @param disability_communicating wgss variable for communicating 
#' @param severity_labeling example severity_labeling = list(no_difficulty = 'no_difficulty' , some_difficulty = 'some_difficulty',  a_lot_of_difficulty = 'a_lot_of_difficulty', cannot_do_at_all = 'cannot_do_at_all')
#' 
#' @return X new columns which are essential for the calculation of education indicators
#' @export


roster_education_core_function <- function(country_assessment = 'BFA',
                                           roster,
                                           household_data,
                                           representative_admin_level = 'admin1',
                                           pop_group = 'status',
                                           ind_age = 'ind_age',
                                           ind_gender = 'ind_gender',
                                           education_access = 'education_access',
                                           education_level_grade = 'education_level_grade',
                                           education_disrupted_climate = 'education_disrupted_climate',
                                           education_disrupted_teacher = 'education_disrupted_teacher',
                                           education_disrupted_displaced = 'education_disrupted_displaced',
                                           education_disrupted_occupation = 'education_disrupted_occupation',
                                           education_barrier = 'education_barrier',
                                           start_school_year = 'september',
                                           beginning_data_collection = 'may',
                                           roster_wgss = NULL, #roster containing the WGSS data, if the WGSS data were collected. If the WGSS indicatros are included in the same roster loop, please re-write here the roster df
                                           disability_seeing = NULL,
                                           disability_hearing = NULL,
                                           disability_walking = NULL,
                                           disability_remembering = NULL,
                                           disability_selfcare = NULL,
                                           disability_communicating = NULL,
                                           severity_labeling = NULL
                                           # Example
                                           # severity_labeling = list(no_difficulty = 'no_difficulty' , some_difficulty = 'some_difficulty',  a_lot_of_difficulty = 'a_lot_of_difficulty', cannot_do_at_all = 'cannot_do_at_all')
) {
  
  
  ## ------  retrieving school-cyles-level-grades for the assessed country 
  file_school_cycle <- "edu_ISCED/resources/UNESCO ISCED Mappings_MSNAcountries_consolidated.xlsx"  ## has to be same of: https://acted.sharepoint.com/:x:/r/sites/IMPACT-Humanitarian_Planning_Prioritization/Shared%20Documents/07.%20Other%20sectoral%20resources%20for%20MSNA/01.%20Education/UNESCO%20ISCED%20Mappings_MSNAcountries_consolidated.xlsx?d=w4925184aeff547aa9687d9ce0e00dd70&csf=1&web=1&e=bFlcvr
  country <- country_assessment 
  info_country_school_structure <- read_school_level_grade_age(file_school_cycle, country)
  summary_info_school <- info_country_school_structure$df1    # DataFrame 1: level code, Learning Level, starting age, duration
  levels_grades_ages <-  info_country_school_structure$df2    # DataFrame 2: level code, Learning Level, Year/Grade, Theoretical Start age, limit age
  
  
  ## ------  integration of the education loop and WGSS loop, should the latter be present in the assessed country
  if (!is.null(roster_wgss)) {
    print('WGSS dataframe provided')
    expected_disability_columns <- c(disability_seeing, disability_hearing, disability_walking,
                                     disability_remembering, disability_selfcare, disability_communicating)
    
    # Filter out any empty names (in case some parameters were left as default empty strings)
    expected_disability_columns <- expected_disability_columns[expected_disability_columns != '']
    
    # Check if all expected columns are present in roster_wgss
    missing_columns <- setdiff(expected_disability_columns, names(roster_wgss))
    
    if (length(missing_columns) > 0) {
      # If there are missing columns, issue a warning
      stop("The following expected disability columns are missing in the WGSS dataset: ", paste(missing_columns, collapse = ", "), ". Execution halted.")
    }
    
    # Compare data frames to check if they are different
    if (!isTRUE(all.equal(roster, roster_wgss, check.attributes = FALSE))) {
      # They are different; identify unique columns in roster_wgss not present in roster
      unique_columns_wgss <- setdiff(names(roster_wgss), names(roster))
      
      # Ensure there's a 'person_id' column in unique_columns_wgss to join on
      if ("person_id" %in% unique_columns_wgss) {
        unique_columns_wgss <- setdiff(unique_columns_wgss, "person_id")
      }
      
      # Join only the unique columns from roster_wgss to roster
      if (length(unique_columns_wgss) > 0) {
        roster <- dplyr::left_join(roster, roster_wgss[c("person_id", unique_columns_wgss)], by = "person_id")
      }
    } else {
      # They are the same; do not do anything more
      message("roster and roster_wgss are identical. No further action taken.")
    }
  }else {
    print('NO WGSS dataframe provided')
  }
  
  
  ## ------ Enquos and checks and stadardization
  edu_cols <- rlang::enquos(education_access, education_disrupted_climate, education_disrupted_teacher, education_disrupted_displaced, education_disrupted_occupation)
  edu_cols <- purrr::map_chr(edu_cols, rlang::as_name)
  
  ind_age_col <- rlang::as_name(rlang::enquo(ind_age))
  ind_gender_col <- rlang::as_name(rlang::enquo(ind_gender))
  
  admin_col <- rlang::as_name(rlang::enquo(representative_admin_level))
  status_col <- rlang::as_name(rlang::enquo(pop_group))
  
  ## sanity check if in_age exist
  if_not_in_stop(roster, ind_age_col, "roster")
  if_not_in_stop(roster, edu_cols, "roster")
  are_cols_numeric (roster, ind_age_col)
  
  ##  modify yes/no to numeric variables -->
  #yes = 1
  #no = 0
  roster <- modify_column_value_yes_no(roster, edu_cols)
  ##  standardize the gender labels -->
  #female/femme = girl
  # male/home = boy
  roster <- modify_gender_values(roster, ind_gender_col)
  
  ## ---- adding info from HH data
  roster <- roster %>%
    left_join(select(household_data, uuid, weight, !!admin_col, !!status_col), by = "uuid")
  
  ## compute the logic variable for the age correction and Add new corrected age column to the roster
  # TRUE --> more than 6 months difference between start of the school and data collection
  # TRUE --> new age columns with (ind_age - 1)
  age_correction  <- calculate_age_correction(start_school_year, beginning_data_collection)
  
  roster <- dplyr::mutate(
    roster,
    corrected_ind_age = dplyr::case_when(
      is.na(!!rlang::sym(ind_age_col)) ~ NA_real_, # Keeps NA values as NA
      age_correction == TRUE ~ !!rlang::sym(ind_age_col) - 1, # Subtract 1 if age_correction is TRUE
      TRUE ~ !!rlang::sym(ind_age_col) # Copies the same value if age_correction is FALSE
    )
  )
  true_age_col <- "corrected_ind_age"  # Direct assignment
  
  education_access_col <- "education_access"
  education_level_grades_col <- education_level_grade
  
  ## Modify the 'roster' dataframe by renaming columns to standardize terminology
  # and facilitate easier data manipulation and analysis later.
  roster <- safe_rename(roster, education_disrupted_climate, "education_disrupted_climate")
  roster <- safe_rename(roster, education_disrupted_teacher, "education_disrupted_teacher")
  roster <- safe_rename(roster, education_disrupted_displaced, "education_disrupted_displaced")
  roster <- safe_rename(roster, education_disrupted_occupation, "education_disrupted_occupation")
  
  
  # 'name_level_grade' is the new column name intended to provide a clearer description of the education levels and grades based on the school system
  roster <- roster %>%
    rename(!!"name_level_grade" := !!sym(education_level_grades_col))
  
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
  
  # IMPORTANT! reducing the dataset to contain only school-aged children
  roster <- roster %>%
    filter(between(!!rlang::sym(true_age_col), 5, 18))
  
  
  ## ------------------------------------------------------------------------------------------------------------------------
  ## ------------------------------ start of the proper add_indicators part  ------------------------------------------------
  
  ## ----- adding clear STRATA columns
  roster <- safe_rename(roster, admin_col, "stratum_admin")
  roster <- safe_rename(roster, status_col, "stratum_status")
  roster <- roster %>%
    mutate(stratum_school_cycle_level_age_category = case_when(
      between(!!rlang::sym(true_age_col), school_level_infos[['level0']]$starting_age, school_level_infos[['level0']]$ending_age) ~ 'level0_age',
      between(!!rlang::sym(true_age_col), school_level_infos[['level1']]$starting_age, school_level_infos[['level1']]$ending_age) ~ 'level1_age',
      between(!!rlang::sym(true_age_col), school_level_infos[['level2']]$starting_age, school_level_infos[['level2']]$ending_age) ~ 'level2_age',
      between(!!rlang::sym(true_age_col), school_level_infos[['level3']]$starting_age, school_level_infos[['level3']]$ending_age) ~ 'level3_age',
      TRUE ~ NA_character_  # For ages outside the defined ranges
    ))
  roster <- roster %>%
    mutate(stratum_gender = case_when(
      sex_member == 1 ~ "boy",
      sex_member == 2 ~ "girl",
      TRUE ~ NA_character_  # for any other case, assign NA
    ))
  #
  filtered_levels <- unique_levels[-1]
  
  ## ----- NUM and DEN for:  % children 5 to 18 y.o. who attended school or any early childhood education program at any time during the 2023-2024 school year 
  roster <- roster %>%
    mutate(
      school_5_18_age = if_else(between(!!rlang::sym(true_age_col), 5, 18), 1, 0, missing = NA_integer_),
      school_5_18_age_accessing = if_else(between(!!rlang::sym(true_age_col), 5, 18) & coalesce(!!rlang::sym(education_access_col), 0) == 1, 1, 0, missing = NA_integer_),
      school_5_18_age_NON_accessing = school_5_18_age - school_5_18_age_accessing,
    )
  
  
  filtered_levels <- unique_levels[-1]
  for (level in filtered_levels) {
    # Extract info for current level
    starting_age <- as.numeric(school_level_infos[[level]]$starting_age)
    ending_age <- as.numeric(school_level_infos[[level]]$ending_age)
    
    # Define dynamic column names
    age_col_name <- paste0(level, "_age")
    roster[[age_col_name]] <- ifelse(roster[[true_age_col]] >= starting_age & roster[[true_age_col]] <= ending_age, 1, 0)
  }
  
  ## ----- NUM and DEN for:  % of children (one year before the official primary school entry age) who are attending an early childhood education program or primary school
  roster <- roster %>%
    mutate(
      level1_minus_one_age = if_else(!!rlang::sym(true_age_col) == (school_level_infos[['level1']]$starting_age - 1), 1, 0, missing = NA_integer_),
      # Participation rate in organised learning
      attending_level0_level1_and_level1_minus_one_age = if_else(!!rlang::sym(true_age_col) == (school_level_infos[['level1']]$starting_age - 1)
                                                                 & (!!rlang::sym('level_code') == 'level0' | !!rlang::sym('level_code') == 'level1'), 1, 0, missing = NA_integer_),
      # for early enrolment
      attending_level1_and_level1_minus_one_age = if_else(!!rlang::sym(true_age_col) == (school_level_infos[['level1']]$starting_age - 1)
                                                          & !!rlang::sym('level_code') == 'level1', 1, 0, missing = NA_integer_)
    )
  
  ## ----- NUM and DEN for:  Net attendance rate (adjusted) - % of school-aged children of level school age currently attending levels
  level_numeric <- seq_along(filtered_levels)
  names(level_numeric) <- filtered_levels
  
  for (level in filtered_levels) {
    starting_age <- as.numeric(school_level_infos[[level]]$starting_age)
    ending_age <- as.numeric(school_level_infos[[level]]$ending_age)
    #
    higher_levels_numeric <- gsub("level", "",  paste(filtered_levels[which(filtered_levels >= level)], collapse = ""))
    attending_col_name <- paste0("attending_level", higher_levels_numeric, "_and_", level, "_age")
    #
    roster[[attending_col_name]] <- ifelse(  roster[[true_age_col]] >= starting_age & roster[[true_age_col]] <= ending_age & as.integer(as.factor(roster$level_code)) >= level_numeric[[level]],1, 0 )
  }
  
  ## ----- NUM and DEN for: Percentage of school-aged children attending school who are at least 2 years above the intended age for grade: primary/lower secondary
  for (level in filtered_levels) {
    accessing_level_col_name <- paste0('attending_',level)
    roster[[accessing_level_col_name]]  <-  if_else(roster[['level_code']] == level, 1, 0, missing = NA_integer_)
  }
  # numerator
  for (level in filtered_levels) {
    overage_level_col_name <- paste0(level, "_overage_learners")
    roster[[overage_level_col_name]] <- ifelse(  roster[['level_code']] == level  & (roster[[true_age_col]] - roster[['limit_age']]) >= 2, 1, 0)
  }
  
  
  ## --------------------------------------------------------------------------------------------------------
  ## --- additional disaggregation on disability level IF the WGS module is present in the dataframe
  if (!is.null(roster_wgss)) {
    
    ##-----  optional disaggregation according to the level of child disability.
    # 2 classifications:
    ##### 1) WGSS: https://www.washingtongroup-disability.com/fileadmin/uploads/wg/WG_Document__5H_-_Analytic_Guidelines_for_the_WG-SS__Severity_Indicators_-_CSPro_.pdf
    ##### 2) USE OF WASHINGTON GROUP QUESTIONS IN  MULTI-SECTOR NEEDS ASSESSMENTS: https://acted.sharepoint.com/sites/IMPACT-Public_health/Shared%20Documents/Forms/SOPs%20Folder.aspx?id=%2Fsites%2FIMPACT%2DPublic%5Fhealth%2FShared%20Documents%2FSectors%2FHealth%2FKey%20concepts%2FWashington%20Group%20%28disability%29%2FGuide%5FWGQs%5Fin%5FMSNAs%5Ftoshare%2Epdf&parent=%2Fsites%2FIMPACT%2DPublic%5Fhealth%2FShared%20Documents%2FSectors%2FHealth%2FKey%20concepts%2FWashington%20Group%20%28disability%29&OR=Teams%2DHL&CT=1712755137438&clickparams=eyJBcHBOYW1lIjoiVGVhbXMtRGVza3RvcCIsIkFwcFZlcnNpb24iOiI0OS8yNDAyMjkyNDUxNyIsIkhhc0ZlZGVyYXRlZFVzZXIiOmZhbHNlfQ%3D%3D
    disability_columns  <- c(disability_seeing, disability_hearing, disability_walking,
                             disability_remembering, disability_selfcare, disability_communicating)
    severity_labeling <- setNames(names(severity_labeling), unlist(severity_labeling))
    
    for (col in disability_columns) {
      if (col %in% names(roster)) { # Check if the column exists
        for (original_value in names(severity_labeling)) {
          roster[[col]] <- gsub(pattern = original_value, replacement = severity_labeling[[original_value]], x = roster[[col]])
        }
      }
    }
    
    
    # Add new columns initialized with default values
    roster$stratum_severity_wgss <- 'none' # Default to none, will adjust based on conditions
    roster$stratum_severity_cut_off <- 'Disability 0' # Assume a default of no disability, will adjust based on conditions
    
    for (i in 1:nrow(roster)) {
      row <- roster[i, ]
      
      # Count the responses for severity classifications
      cannot_do_at_all_count <- sum(row[disability_columns] == 'cannot_do_at_all')
      a_lot_of_difficulty_count <- sum(row[disability_columns] == 'a_lot_of_difficulty')
      some_difficulty_count <- sum(row[disability_columns] == 'some_difficulty')
      no_difficulty_count <- sum(row[disability_columns] == 'no_difficulty')
      
      # severity_wgss classification
      if (cannot_do_at_all_count >= 1) {
        roster$stratum_severity_wgss[i] <- 'severe'
      } else if (a_lot_of_difficulty_count >= 1) {
        roster$stratum_severity_wgss[i] <- 'moderate'
      } else if (some_difficulty_count >= 1) {
        roster$stratum_severity_wgss[i] <- 'milder'
      } else if (no_difficulty_count == length(disability_columns)) {
        roster$stratum_severity_wgss[i] <- 'none'
      }
      
      
      # severity_cut-off classification, we focus on disability 3
      # Disability 3
      if (a_lot_of_difficulty_count >= 1 || cannot_do_at_all_count >= 1) {
        roster$stratum_severity_cut_off[i] <- 'Disability 3'
      }
      # Disability 2
      else if (some_difficulty_count >= 2 || a_lot_of_difficulty_count >= 1 || cannot_do_at_all_count >= 1) {
        roster$stratum_severity_cut_off[i] <- 'Disability 2'
      }
      # Disability 1
      else if (some_difficulty_count + a_lot_of_difficulty_count + cannot_do_at_all_count >= 1) {
        roster$stratum_severity_cut_off[i] <- 'Disability 1'
      }
      else  {roster$stratum_severity_cut_off[i] <- 'No disability'}
    }
  }
  
  return(roster)
}## end roster_education_core_function
