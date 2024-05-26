library(impactR.utils)

dap <- import_full_xlsx("data-raw/analysis_dap.xlsx")

survey_update <- dap$update_survey
choices_update <- dap$update_choices

kobo <- import_full_xlsx("data-raw/REACH_2024_MSNA-kobo-tool_draft_v9.xlsx")
survey <- kobo$survey
choices <- kobo$choices

survey_update <- bind_rows(
  survey,
  survey_update
)

choices_update <- bind_rows(
  choices,
  choices_update |> mutate(
    across(
      everything(),
      \(x) as.character(x)
    )
  )
)

loa <- dap$dap_v1

usethis::use_data(loa, overwrite = TRUE)
usethis::use_data(survey_update, overwrite = TRUE)
usethis::use_data(choices_update, overwrite = TRUE)
