#' @title add column edu_ind_gender
#'
#' @param roster A data frame of individual-level data.
#' @param gender_col The individual age column.
#' @return 1 new columns with the corrected gender
#' @export


add_edu_gender_values <- function(roster, gender_col = 'ind_gender') {
  # Check if the target column exists in the data
  if (!gender_col %in% names(roster)) {
    warning(paste("Column", gender_col, "not found in data. No changes made."), call. = FALSE)
    return(roster)
  }

  # Replace gender labels with standardized text codes and add as a new column
  roster <- roster %>%
    mutate(edu_school_child_gender = case_when(
      tolower(!!sym(gender_col)) %in% c("femme", "féminin", "feminin", "female", "woman", "girl", "2") ~ 'girl',
      tolower(!!sym(gender_col)) %in% c("homme", "masculin", "male", "man", "boy", "1") ~ 'boy',
      !!sym(gender_col) %in% c("no_answer") ~ 'idk',
      !!sym(gender_col) %in% c("other", "prefer_not_to_answer") ~ 'pnta',
      TRUE ~ NA_character_  # Use NA_character_ to maintain type consistency
    ))

  return(roster)
}
