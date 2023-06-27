#' @title Calculate main food security indicators
#'
#' @param df Data
#' @param fcs_cereal Cereals component column
#' @param fcs_legumes Legumes component column
#' @param fcs_dairy Dairy component column
#' @param fcs_meat Meat component column
#' @param fcs_veg Vegetables component column
#' @param fcs_fruit Fruit component column
#' @param fcs_oil Oil component column
#' @param fcs_sugar Sugar component column
#' @param fcs_cat Cut-offs categories, either "normal" (21.5/35) or "alternate" (28/42)
#' @param hhs_lev1_nofoodhh Component column: No food of any kind in the house
#' @param hhs_lev2_nofoodhh Follow-up frequency column
#' @param hhs_lev1_sleephungry Component column: Go to sleep hungry because there was not enough food
#' @param hhs_lev2_sleephungry Follow-up frequency column
#' @param hhs_lev1_alldaynight Component column: Go a whole day and night without eating
#' @param hhs_lev2_alldaynight Follow-up frequency column
#' @param hhs_level1_codes Character vector of at least "Yes" and "No" codes (in this order), e.g. c("yes", "no")
#' @param hhs_level2_codes Character vector of at least frequencies codes, in the following order: "Rarely", "Sometimes", "Often", e.g. c("rarely", "sometimes", "often")
#' @param rcsi_lesspreferred Component column: Rely on less preferred and less expensive food
#' @param rcsi_borrowfood Component column: Borrow food or rely on help from friends or relatives
#' @param rcsi_limitportion Component column: Limit portion size at mealtime
#' @param rcsi_restrict Component column: Restrict consumption by adults in order for small children to eat
#' @param rcsi_reducemeals Component column: Reduce the number of meals eaten in a day
#' @param lcsi_stress_1 Component column: Stress strategy 1
#' @param lcsi_stress_2 Component column: Stress strategy 2
#' @param lcsi_stress_3 Component column: Stress strategy 3
#' @param lcsi_stress_4 Component column: Stress strategy 4
#' @param lcsi_crisis_1 Component column: Crisis strategy 1
#' @param lcsi_crisis_2 Component column: Crisis strategy 2
#' @param lcsi_crisis_3 Component column: Crisis strategy 3
#' @param lcsi_emergency_1 Component column: Emergency strategy 1
#' @param lcsi_emergency_2 Component column: Emergency strategy 2
#' @param lcsi_emergency_3 Component column: Emergency strategy 3
#' @param lcsi_level_codes Character vector of at responses codes, in the following order: ""Yes", "No, exhausted", "No, no need", "No, not applicable", e.g. c("yes", "exhausted", "no_need", "not_applicable")
#'
#'
#' @return All columns produced by the followingfunctions: `fcs()`, `hhs()`, `rcsi()`, `lcs()`, `fcm()`, `fcp()` and `fclp()`.
#'
#' @export
foodsec <- function(df,
                    fcs_cereal = "fcs_cereal",
                    fcs_legumes = "fcs_legumes",
                    fcs_dairy = "fcs_dairy",
                    fcs_meat = "fcs_meat",
                    fcs_veg = "fcs_veg",
                    fcs_fruit = "fcs_fruit",
                    fcs_oil = "fcs_oil",
                    fcs_sugar = "fcs_sugar",
                    fcs_cat = "normal",
                    hhs_lev1_nofoodhh = "hhs_lev1_nofoodhh",
                    hhs_lev2_nofoodhh = "hhs_lev2_nofoodhh",
                    hhs_lev1_sleephungry = "hhs_lev1_sleephungry",
                    hhs_lev2_sleephungry = "hhs_lev2_sleephungry",
                    hhs_lev1_alldaynight = "hhs_lev1_alldaynight",
                    hhs_lev2_alldaynight = "hhs_lev2_alldaynight",
                    hhs_level1_codes = c("yes", "no"),
                    hhs_level2_codes = c("rarely", "sometimes", "often"),
                    rcsi_lesspreferred = "rcsi_lesspreferred",
                    rcsi_borrowfood = "rcsi_borrowfood",
                    rcsi_limitportion = "rcsi_limitportion",
                    rcsi_restrict = "rcsi_restrict",
                    rcsi_reducemeals = "rcsi_reducemeals",
                    lcsi_stress_1 = "lcsi_stress_1",
                    lcsi_stress_2 = "lcsi_stress_2",
                    lcsi_stress_3 = "lcsi_stress_3",
                    lcsi_stress_4 = "lcsi_stress_4",
                    lcsi_crisis_1 = "lcsi_crisis_1",
                    lcsi_crisis_2 = "lcsi_crisis_2",
                    lcsi_crisis_3 = "lcsi_crisis_3",
                    lcsi_emergency_1 = "lcsi_emergency_1",
                    lcsi_emergency_2 = "lcsi_emergency_2",
                    lcsi_emergency_3 = "lcsi_emergency_3",
                    lcsi_level_codes = c("yes", "exhausted", "no_need", "not_applicable")){

  df <- fcs(
    df,
    {{ fcs_cereal }},
    {{ fcs_legumes }},
    {{ fcs_dairy }},
    {{ fcs_meat }},
    {{ fcs_veg }},
    {{ fcs_fruit }},
    {{ fcs_oil }},
    {{ fcs_sugar }},
    cat = fcs_cat)

  df <- hhs(
    df,
    {{ hhs_lev1_nofoodhh }},
    {{ hhs_lev2_nofoodhh }},
    {{ hhs_lev1_sleephungry }},
    {{ hhs_lev2_sleephungry }},
    {{ hhs_lev1_alldaynight }},
    {{ hhs_lev2_alldaynight }},
    level1_codes = hhs_level1_codes,
    level2_codes = hhs_level2_codes)

  df <- rcsi(
    df,
    {{ rcsi_lesspreferred }},
    {{ rcsi_borrowfood }},
    {{ rcsi_limitportion }},
    {{ rcsi_restrict }},
    {{ rcsi_reducemeals }})

  # LCSI - with exhaustion
  df <- lcsi(
    df,
    {{ lcsi_stress_1 }},
    {{ lcsi_stress_2 }},
    {{ lcsi_stress_3 }},
    {{ lcsi_stress_4 }},
    {{ lcsi_crisis_1 }},
    {{ lcsi_crisis_2 }},
    {{ lcsi_crisis_3 }},
    {{ lcsi_emergency_1 }},
    {{ lcsi_emergency_2 }},
    {{ lcsi_emergency_3 }},
    level_codes = lcsi_level_codes)

  # LCSI - without exhaustion
  df <- lcsi(
    df,
    {{ lcsi_stress_1 }},
    {{ lcsi_stress_2 }},
    {{ lcsi_stress_3 }},
    {{ lcsi_stress_4 }},
    {{ lcsi_crisis_1 }},
    {{ lcsi_crisis_2 }},
    {{ lcsi_crisis_3 }},
    {{ lcsi_emergency_1 }},
    {{ lcsi_emergency_2 }},
    {{ lcsi_emergency_3 }},
    level_codes = lcsi_level_codes,
    with_exhaustion = FALSE)



  df <- fcm_cell(df)

  df <- fcp(df)

  df <- fclcp(df)


  return(df)
}
