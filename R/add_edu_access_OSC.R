#' @title Modify access column to better define and include out of school children (OSC)
#' @description
#' yes == accessing
#' no == non accessing == OSC
#' NA == no school-age child
#'
#' @param roster A data frame of individual-level data.
#' @param education_access The individual access indicator column.
#'
#' @return 1 modified column
#' @export


add_edu_access_OSC  <- function(roster,
                                education_access = 'education_access'){

  roster <- roster %>%
    mutate(
      !!education_access := case_when(
        .data[[education_access]] %in% c("yes", "Yes", "oui", 1, '1') ~ "yes",  # If the column entry matches 'yes', keep as 'yes'
        !(.data[[education_access]] %in% c("yes", "Yes", "oui", 1, '1')) & edu_is_school_child == 1 ~ "no",  # If not 'yes' and child is school age, write 'no'
        edu_is_school_child == 0 ~ NA_character_,  # If not a school child, write NA
        TRUE ~ .data[[education_access]]  # Otherwise keep the original value
      )
    )

}
