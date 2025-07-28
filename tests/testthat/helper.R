library(stringr)
library(dplyr)
library(tidyr)

generate_survey_choice_combinations <- function(
  question_name,
  answer_options,
  stand_alone_opts = c("dnk", "pnta"),
  sep = "/",
  min_choices = 1,
  max_choices = length(answer_options) - 1
) {
  invalid <- setdiff(stand_alone_opts, answer_options)
  if (length(invalid) > 0) {
    stop(
      "These stand_alone_opts are not in answer_options: ",
      paste(invalid, collapse = ", ")
    )
  }
  # 1. Build column names
  cols <- stringr::str_glue("{question_name}{sep}{answer_options}")

  # 2. All binary combos
  df <- expand.grid(rep(list(0:1), length(cols))) |>
    rlang::set_names(cols) |>
    as.data.frame()

  # 3. Count selections
  df$tot <- rowSums(df)

  # 4. Filter by total count
  df <- df |>
    dplyr::filter(tot >= min_choices, tot <= max_choices)

  # 5. Enforce stand‑alone constraints
  sa_cols <- stringr::str_glue("{question_name}/{stand_alone_opts}")

  for (col in sa_cols) {
    df <- df |>
      dplyr::filter(!(.data[[col]] == 1 & tot > 1))
  }

  df
}
