add_msni <- function(
  df,
  comp_foodsec_score = "comp_foodsec_score",
  comp_snfi_score = "comp_snfi_score",
  comp_wash_score = "comp_wash_score",
  comp_prot_score = "comp_prot_score",
  comp_health_score = "comp_health_score",
  comp_edu_score = "comp_edu_score"){

  #------ Checks

  # All vars
  comp_scores <- c(comp_foodsec_score, comp_snfi_score, comp_wash_score, comp_prot_score, comp_health_score, comp_edu_score)

  # Check that variables are in df
  if_not_in_stop(df, comp_scores, "df")

  # Check that all values are in set 1:5
  are_values_in_set(df, comp_scores, 1:5)

  #------ Take the maximum

  df <- impactR.utils::row_optimum(
    df = df,
    !!!rlang::syms(comp_scores),
    optimum = "max",
    max_name = "msni_score",
    na_rm = TRUE
  )

  #------ Create dummy "in need"

  df <- is_in_need(
    df = df,
    score = "msni_score",
    new_colname = "msni_in_need"
  )

  return(df)

}
