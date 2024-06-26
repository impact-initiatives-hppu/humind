#' @title Prepare dummy variables for education indicators (individual data)
#'
#'
#' @param country_assessment  Can input either country code or name, case-insensitive
#'
#' @return data frame with ISCED info
#' @export
read_ISCED_info <- function(country_assessment = 'BFA') {
  file_school_cycle <- "UNESCO ISCED Mappings_MSNAcountries_consolidated.xlsx"  ## has to be same of: https://acted.sharepoint.com/:x:/r/sites/IMPACT-Humanitarian_Planning_Prioritization/Shared%20Documents/07.%20Other%20sectoral%20resources%20for%20MSNA/01.%20Education/UNESCO%20ISCED%20Mappings_MSNAcountries_consolidated.xlsx?d=w4925184aeff547aa9687d9ce0e00dd70&csf=1&web=1&e=bFlcvr

  #file_school_cycle <- "inst/extdata/edu_ISCED/resources/UNESCO ISCED Mappings_MSNAcountries_consolidated.xlsx"  ## has to be same of: https://acted.sharepoint.com/:x:/r/sites/IMPACT-Humanitarian_Planning_Prioritization/Shared%20Documents/07.%20Other%20sectoral%20resources%20for%20MSNA/01.%20Education/UNESCO%20ISCED%20Mappings_MSNAcountries_consolidated.xlsx?d=w4925184aeff547aa9687d9ce0e00dd70&csf=1&web=1&e=bFlcvr
  country <- country_assessment
  df <- readxl::read_excel(file_school_cycle, sheet = "Compiled_Levels_Grades")

  # Convert the country input and dataframe columns to lowercase for case-insensitive comparison
  country_input_lower <- tolower(country)

    # Check if the country exists in the dataframe
    if(sum(tolower(df$`country code`) == country_input_lower | tolower(df$country) == country_input_lower) == 0){
      warning(sprintf("The country '%s' does not exist in the dataset.", country_input))
      return(NULL)
    }

    # Filter data for the specified country by code or name, case-insensitive
    country_df <- dplyr::filter(df, tolower(`country code`) == country_input_lower | tolower(country) == country_input_lower)

    # DataFrame 1: level code, Learning Level, starting age, duration
    summary_info_school <- country_df %>%
      dplyr::group_by(`level code`, `learning level`) %>%
      dplyr::summarise(starting_age = min(`theoretical start age`),
                       duration = dplyr::n(),
                       .groups = 'drop')

    # Adjust for level0 duration if both level0 and level1 exist
    if ("level0" %in% summary_info_school$`level code` && "level1" %in% summary_info_school$`level code`) {
      starting_age_level0 <- summary_info_school$starting_age[summary_info_school$`level code` == "level0"]
      starting_age_level1 <- summary_info_school$starting_age[summary_info_school$`level code` == "level1"]
      duration_level0 <- starting_age_level1 - starting_age_level0

      summary_info_school <- summary_info_school %>%
        mutate(duration = ifelse(`level code` == "level0", duration_level0, duration))
    }

    # DataFrame 2: level code, Learning Level, Year/Grade, Theoretical Start age, limit age
    levels_grades_ages <- country_df %>%
      dplyr::select(`level code`, `learning level`, `year-grade`, `theoretical start age`,  `name -- for kobo`)

    levels_grades_ages <- levels_grades_ages %>%
      rename(
        level_code = `level code`,
        name_level = `learning level`,
        starting_age = `theoretical start age`,
        name_level_grade = `name -- for kobo`,
        grade = `year-grade`
      )

    summary_info_school <- summary_info_school %>%
      rename(
        level_code = `level code`,
        name_level = `learning level`
      )

    return(list(summary_info_school = summary_info_school, levels_grades_ages = levels_grades_ages))

  ## ------  retrieving school-cyles-level-grades for the assessed country
  #
  # info_country_school_structure <- read_school_level_grade_age(file_school_cycle, country)
  # summary_info_school <- info_country_school_structure$df1    # DataFrame 1: level code, Learning Level, starting age, duration
  # levels_grades_ages <-  info_country_school_structure$df2    # DataFrame 2: level code, Learning Level, Year/Grade, Theoretical Start age, limit age
  #
}
