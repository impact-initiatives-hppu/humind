#' @title Prepare dummy variables for education indicators (individual data)
#'
#'
#' @param country_assessment  Can input either country code or name, case-insensitive
#' @param roster A data frame of individual-level data.
#' @param household_data A data frame of hh-level data.
#' @param ind_age The individual age column.
#' @param ind_gender The individual gender column.
#' @param education_access The individual access indicator column.
#' @param start_school_year NUMERIC of the month when the school year has started.
#' @param education_level_grade The individual level and grade column.
#'
#'
#' @return X new columns which are essential for the calculation of education indicators
#' @export


add_edu_indicators  <- function(roster,
                                household_data,
                                ind_age = 'ind_age',
                                ind_gender = 'ind_gender',
                                education_access_col = 'education_access',
                                country_MSNA = 'BFA',
                                start_school_year = 9,
                                education_level_grade_col = 'education_level_grade'){

  roster <- roster %>%
    #Add column edu_ind_corrected_age with the revised and corrected individual age according to the start of the data collection wrt the start f the school-year
    #Add a column edu_is_school_child
    add_edu_corrected_age(household_data = household_data, start_school_year = start_school_year, age_col = ind_age) %>%

    # add column edu_school_child_gender with 'boy'/'girl'
    add_edu_gender_values(gender_col = ind_gender) %>%

    # IMPORTANT: THE INDICATOR MUST COMPLAY WITH THE MSNA GUIDANCE AND LOGIC
    # Add columns to use for calculation of the composite indicators: Net attendance, early-enrollment, overage learners
    add_edu_level_grade_indicators(country_assessment = country_MSNA, education_access = education_access_col, education_level_grade = education_level_grade_col)%>%

    # Add a column edu_school_cycle with ECE, primary (1 or 2 cycles) and secondary
    add_edu_school_cycle(country_assessment = country_MSNA)%>%

    # Modify access column to better define and include out of school children (OSC) yes == accessing,  no == non accessing == OSC, NA == no school-age child
    add_edu_access_OSC(education_access = education_access_col)

  return(roster)
}
