source()

# Analysis groups ---------------------------------------------------------

# List of grouping variables
group_vars <- list("admin1", "resp_gender", "hoh_gender", "hoh_age_cat")

# Add this list of variables to loop (including weights, and stratum if relevant), joining by uuid
loop <- df_diff(loop, main, uuid) |>
  left_join(
    main |> select(uuid, weight, !!!unlist(group_vars)),
    by = "uuid"
  )


# Prepare design and kobo -------------------------------------------------

# Design main - weighted
design_main_w <- main |>
  as_survey_design(weight = weight)

# Design main - unweighted
design_main_unw <- main |>
  mutate(weight = 1) |>
  as_survey_design(weight = weight)

# Design loop - weighted
design_loop_w <- loop |>
  as_survey_design(weight = weight)

# Design loop - unweighted
design_loop_unw <- loop |>
  mutate(weight = 1) |>
  as_survey_design(weight = weight)

# Survey
survey <- survey_update |>
  split_survey(type) |>
  rename(label = label_english)

# Choices
choices <- choices_update |>
  rename(label = label_english)



# Prepare analysis --------------------------------------------------------

# Bind var_denom when ratio with a ","
loa <- unite(loa, var, var, var_denom, sep = ",", na.rm = TRUE)

loa_main <- loa |> filter(dataset == "main")
loa_loop <- loa |> filter(dataset == "loop")
loa_main_unw <- loa_main |> filter(weighted == "no")
loa_loop_unw <- loa_loop |> filter(weighted == "no")
loa_main_w <- loa_main |> filter(weighted == "yes")
loa_loop_w <- loa_loop |> filter(weighted == "yes")



# Run analysis ------------------------------------------------------------


# Main analysis - weighted
if (nrow(loa_main_w) > 0) {
  an_main_w <- impactR.analysis::kobo_analysis_from_dap_group(
    design_main_w,
    loa_main_w,
    survey,
    choices,
    l_group = group_vars,
    choices_sep = "/")
} else {
  an_main_w <- tibble()
}

# Main analysis - unweighted
if (nrow(loa_main_unw) > 0) {
  an_main_unw <- impactR.analysis::kobo_analysis_from_dap_group(
    design_main_unw,
    loa_main_unw,
    survey,
    choices,
    l_group = group_vars,
    choices_sep = "/")
} else {
  an_main_unw <- tibble()
}

# Loop analysis - weighted
if (nrow(loa_loop_w) > 0) {
  an_loop_w <- impactR.analysis::kobo_analysis_from_dap_group(
    design_loop_w,
    loa_loop_w,
    survey,
    choices,
    l_group = group_vars,
    choices_sep = "/")
} else {
  an_loop_w <- tibble()
}

# Loop analysis - unweighted
if (nrow(loa_loop_unw) > 0) {
  an_loop_unw <- impactR.analysis::kobo_analysis_from_dap(
    design_loop_unw,
    loa_loop_unw,
    survey,
    choices,
    l_group = group_vars,
    choices_sep = "/")
} else {
  an_loop_unw <- tibble()
}


# Bind all, view, and save ------------------------------------------------

# Bind all
an <- bind_rows(an_main_w, an_main_unw, an_loop_w, an_loop_unw)
